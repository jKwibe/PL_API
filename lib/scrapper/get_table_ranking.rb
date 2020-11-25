module Scrapper
  class Scrape
    def initialize
      route = "https://www.premierleague.com/tables"
      html = open(route)
      @main_doc = Nokogiri::HTML(html)
    end

    def fetch_table_data
      # Fetch table data from the route
      data = @main_doc.css('.allTablesContainer
                            .wrapper.col-12  .tableContainer
                            .table.wrapper table
                            .tableBodyContainer.isPL tr')

      valid_tr = data.select.with_index do |_, index|
        index.even? || index.zero?
      end

      p valid_tr[0].children[5]
      #

      all_team_values = valid_tr.map do |child|
        {
          child.children[5].css('a span.long')[0].children[0].text => {
              position: child.children[3].children[1].children[0].text,
              team_name_short: child.children[5].css('a span.short')[0].children[0].text,
              team_logo: child.children[5].css('a span.badge.badge-image-container img')[0].attributes['src'].value
          }
        }
      end

      # p all_team_values

    end
  end
end