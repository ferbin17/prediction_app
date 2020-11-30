namespace :prediction_app do
  desc "Set up PL for Prediction"
  task set_up_pl: :environment do
    league = League.find_or_create_by(name: "Premier League", code: "PL", no_of_teams: 20)
    league.fetch_teams_and_their_matches
    league.update_league_table
    league.calculate_gws_score
  end
end
