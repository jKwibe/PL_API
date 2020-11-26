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

    def fetch_team_data(team_id, team_name_slug)
      route = "https://www.premierleague.com/clubs/#{team_id}/#{team_name_slug}/squad"
      html = open(route)
      main_doc = Nokogiri::HTML(html)
      data = main_doc.css("ul.squadListContainer li" )
    end

    private

    def teams_names
      all_table_data.map do |child|
        {
            team_id: child.attributes['data-filtered-table-row'].value.to_i,
            team_name: child.children[5].css('a span.long')[0].children[0].text,
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