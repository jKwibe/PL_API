require 'activerecord-import'
module Scrapper
  class Scrape

    def fetch_table_data
      valid_tr = all_table_data

      valid_tr.map do |child|
        {
          id: child.attributes['data-filtered-table-row'].value.to_i,
          team_name: child.children[5].css('a span.long')[0].children[0].text,
          # position: child.children[3].children[1].children[0].text,
          team_name_short: child.children[5].css('a span.short')[0].children[0].text,
          team_logo: child.children[5].css('a span.badge.badge-image-container img')[0].attributes['src'].value,
          # games_played: child.children[7].children.first.text,
          # games_won: child.children[9].children.first.text,
          # games_drawn: child.children[11].children.first.text,
          # games_lost: child.children[13].children.first.text,
          # GF: child.children[15].children.first.text,
          # GA: child.children[17].children.first.text,
          # GD: child.children[19].children.first.text.strip,
          # points: child.children[21].children.first.text.strip
        }
      end
    end

    def import_teams_data
      teams = fetch_table_data.map do |team_data|
        Team.new(team_data)
      end

      players = team_players_info.map do |player|
        Player.new(player)
      end

      begin
        Team.import(teams)
        p "Team import successful"
        Player.import(players)
        p "Player Import was successful"
      rescue ActiveRecord::RecordNotUnique => e
        print "The active record is not unique"
      rescue ActiveRecord::StatementInvalid => e
        print "The relationship does not exist"
      rescue StandardError => e
        p "Something went wrong while importing data"
      end
    end

    def team_players_info
      raw_player_data = teams_names.map do |team_info|
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
      @team_data ||= teams_names.map do |team_info|
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
    end

    private

    def connect_clubs_data(team_id, team_name_slug, final_endpoint)
      route = "https://www.premierleague.com/clubs/#{team_id}/#{team_name_slug}/#{final_endpoint}"
      html = open(route)
      Nokogiri::HTML(html)
    end

    def fetch_squad_team_data(team_id, team_name_slug, final_endpoint= "squad")
      [connect_clubs_data(team_id, team_name_slug, final_endpoint).css("ul.squadListContainer li" ), team_id] # To have the team Id for the players
    end

    def fetch_raw_squad_years(team_id, team_name_slug, final_endpoint)
      connect_clubs_data(team_id, team_name_slug, final_endpoint).css("div.current ul.dropdownList li")
    end

    def teams_names # move to base
      @slug ||= all_table_data.map do |child|
        {
            team_id: child.attributes['data-filtered-table-row'].value.to_i,
            teams_name_slug: child.children[5].css('a span.long')[0].children[0].text.gsub(" ", "-")
        }
      end
    end

    def all_table_data # Move to base
      route = "https://www.premierleague.com/tables"
      html = open(route)
      main_doc = Nokogiri::HTML(html)

      # Fetch table data from the route
      data = main_doc.css('.allTablesContainer
                            .wrapper.col-12  .tableContainer
                            .table.wrapper table
                            .tableBodyContainer.isPL tr')

      data.select.with_index do |_, index|
        index.even? || index.zero?
      end
    end

    def database_import(object, data) # helper method to import data to a database
      teams = data.map do |object_data|
        object.new(object_data)
      end
      begin
        object.import(teams)
        p "success"
      rescue => e
        p e
      end
    end
  end
end
