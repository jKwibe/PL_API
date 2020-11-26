module Scrapper
  class Scrape

    def fetch_table_data
      valid_tr = all_table_data

      valid_tr.map do |child|
        {
          team_id: child.attributes['data-filtered-table-row'].value.to_i,
          team_name: child.children[5].css('a span.long')[0].children[0].text,
          position: child.children[3].children[1].children[0].text,
          team_name_short: child.children[5].css('a span.short')[0].children[0].text,
          team_logo: child.children[5].css('a span.badge.badge-image-container img')[0].attributes['src'].value,
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
      team_player_data = teams_names.map do |team_info|
        fetch_team_data(team_info[:team_id], team_info[:teams_name_slug])
      end

      da = team_player_data.map do |data|
        data[0].map do |pl|
          plito = {}
          pl.css('a.playerOverviewCard .squadPlayerHeader').each do |player|
            # p player.css('img')[0].attributes["data-player"].value
            # p player.css('span.playerCardInfo h4.name')[0].children[0].text
            plito[:player_id] = player.css('img')[0].attributes["data-player"].value
            plito[:player_name] = player.css('span.playerCardInfo h4.name')[0].children[0].text
            plito[:team_id] = data[1]
          end
          plito if !plito.empty?
        end.compact
      end

       @da||=da

      p @da.last
      p "\n"
      p @da.first


      # team = {:team_id=>21, :team_name=>"Tottenham Hotspur", :teams_name_slug=>"Tottenham-Hotspur"}
      # data = fetch_team_data(team[:team_id], team[:teams_name_slug])
      # player_id = data.css('a .squadPlayerHeader img')[0].attributes["data-player"].value
      # player_picture = data.css('a .squadPlayerHeader img')[0].attributes["src"].value
      # player_name = data.css('a .squadPlayerHeader span.playerCardInfo h4.name')[0].children[0].text
      # player_name = data.css('a .squadPlayerHeader span.playerCardInfo span.number')[0].children[0].text
      # player_name = data.css('a .squadPlayerHeader span.playerCardInfo span.position')[0].children[0].text
      # data[0].map do |pl|
      #   plito = {}
      #   pl.css('a.playerOverviewCard .squadPlayerHeader').each do |player|
      #     # p player.css('img')[0].attributes["data-player"].value
      #     # p player.css('span.playerCardInfo h4.name')[0].children[0].text
      #     plito[:player_id] = player.css('img')[0].attributes["data-player"].value
      #     plito[:player_name] = player.css('span.playerCardInfo h4.name')[0].children[0].text
      #     plito[:team_id] = data[1]
      #   end
      #   plito if !plito.empty?
      # end.compact
      end
    private

    def fetch_team_data(team_id, team_name_slug)
      route = "https://www.premierleague.com/clubs/#{team_id}/#{team_name_slug}/squad"
      html = open(route)
      main_doc = Nokogiri::HTML(html)
      [main_doc.css("ul.squadListContainer li" ), team_id] # To have the team Id for the players
    end

    def teams_names
      all_table_data.map do |child|
        {
            team_id: child.attributes['data-filtered-table-row'].value.to_i,
            teams_name_slug: child.children[5].css('a span.long')[0].children[0].text.gsub(" ", "-")
        }
      end
    end

    def all_table_data
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
  end
end