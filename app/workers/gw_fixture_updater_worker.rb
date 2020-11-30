class GwFixtureUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: false, backtrace: true

  def perform(game_week_id, fixture_responses)
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week
      game_week.fetch_fixtures(fixture_responses)
    end
  end
end
