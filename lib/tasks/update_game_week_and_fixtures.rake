namespace :prediction_app do
  desc "Update PL Gameweeks and Fixtures"
  task update_gw_and_fixtures: :environment do
    league = League.find_by(name: "Premier League", code: "PL")
    league.update_gws_and_fixtures if league.present?
  end
end
