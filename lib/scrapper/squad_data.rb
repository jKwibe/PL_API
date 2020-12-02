require 'activerecord-import'
require_relative './base'
module Scrapper
  class Scrape < Base

    def fetch_table_data
      all_table_data.map do |child|
        {
          team_id: child.attributes['data-filtered-table-row'].value.to_i,
          position: child.children[3].children[1].children[0].text,
          games_played: child.children[7].children.first.text,
          games_won: child.children[9].children.first.text,
          games_drawn: child.children[11].children.first.text,
          games_lost: child.children[13].children.first.text,
          GF: child.children[15].children.first.text,
          GA: child.children[17].children.first.text,
          GD: child.children[19].children.first.text.strip,
          points: child.children[21].children.first.text.strip
        }
      end
    end

    def team_players_info
      raw_player_data = team_slug_gen.map do |team_info|
        fetch_squad_team_data(team_info[:team_id], team_info[:teams_name_slug])
      end

      raw_player_data.flat_map do |data|
        data[0].map do |raw|
          single_player_info = {}
          raw.css('a.playerOverviewCard .squadPlayerHeader').each do |player|
            single_player_info[:player_uid] = player.css('img')[0].attributes["data-player"].value
            single_player_info[:player_name] = player.css('span.playerCardInfo h4.name')[0].children[0].text
            single_player_info[:team_id] = data[1]
          end
          single_player_info if single_player_info.size > 0
        end.compact
      end
    end

    # Get Team Squad Information
    def collect_teams_data
      @team_data ||= team_slug_gen.map do |team_info|
        connect_clubs_data(team_info[:team_id], team_info[:teams_name_slug], "directory")
      end

      @team_data.reduce([]) do |team_data, raw_data |
        hash = {}
        club_header = raw_data.css(".clubHero.clubColourBg")
        hash[:team_logo] = club_header.css(".clubDetailsContainer .badgeContainer picture").first.children[1].attributes["srcset"].value.prepend("https:")
        hash[:team_name] = club_header.css(".clubDetailsContainer .clubDetails").first.children[1].children.first.text
        hash[:manager_name] = raw_data.css(".directoryCards .col-6.col-6-m .card .cardBody")[0].children[1].children.first.text
        hash[:id] = club_header[0].attributes["data-id"].value.to_i
        team_data << hash
      end

    end

    def db_import_team
      database_import(Team, collect_teams_data)
      database_import(Player, team_players_info )
    end

    private

    def fetch_squad_team_data(team_id, team_name_slug, final_endpoint= "squad")
      [connect_clubs_data(team_id, team_name_slug, final_endpoint).css("ul.squadListContainer li" ), team_id] # To have the team Id for the players
    end

    def fetch_raw_squad_years(team_id, team_name_slug, final_endpoint)
      connect_clubs_data(team_id, team_name_slug, final_endpoint).css("div.current ul.dropdownList li")
    end

    def database_import(object, data) # helper method to import data to a database
      teams = data.map do |object_data|
        object.new(object_data)
      end
      begin
        object.import(teams)
        p "#{object} imported successfully"
      rescue => e
        p e
      end
    end
  end
end
