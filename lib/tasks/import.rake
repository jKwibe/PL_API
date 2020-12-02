require_relative '../scrapper/squad_data'

namespace :scrapper do
  desc "Initializing The Scrapper"

  task run_scrapper: :environment do
    scrapper = Scrapper::Scrape.new
    p scrapper.fetch_table_data
    # Team.import(t)
  end
end