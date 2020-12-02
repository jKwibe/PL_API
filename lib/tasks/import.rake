require_relative '../scrapper/get_table_ranking'

namespace :scrapper do
  desc "Initializing The Scrapper"

  task run_scrapper: :environment do
    scrapper = Scrapper::Scrape.new
    # p scrapper.fetch_team_data(7, "Everton")[0]
    p scrapper.db_import_team
    # Team.import(t)
  end
end