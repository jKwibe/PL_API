module Scrapper
  class Base
    MAIN_URL = "https://www.premierleague.com"

    def connect_clubs_data(team_id, team_name_slug, final_endpoint)
      route = "#{MAIN_URL}/clubs/#{team_id}/#{team_name_slug}/#{final_endpoint}"
      html = open(route)
      Nokogiri::HTML(html)
    end

    def connect_table_data
      route = "#{MAIN_URL}/tables"
      html = open(route)
      Nokogiri::HTML(html)
    end

    def all_table_data
      table_conn = connect_table_data.css('.allTablesContainer
                            .wrapper.col-12  .tableContainer
                            .table.wrapper table
                            .tableBodyContainer.isPL tr')

      table_conn.select.with_index do |_, index|
        index.even? || index.zero?
      end
    end


    def team_slug_gen
      @slug ||= all_table_data.map do |child|
        {
            team_id: child.attributes['data-filtered-table-row'].value.to_i,
            teams_name_slug: child.children[5].css('a span.long')[0].children[0].text.gsub(" ", "-")
        }
      end
    end

  end
end