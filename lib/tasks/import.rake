require_relative '../scrapper/get_table_ranking'

namespace :scrapper do
  desc "Initializing The Scrapper"

  task run_scrapper: :environment do
    scrpe = Scrapper::Scrape.new
    scrpe.fetch_table_data
  end
end