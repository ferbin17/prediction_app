class UpdateGwFixtureWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: 0, backtrace: true

  def perform(league_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting UpdateGwFixtureWorker at #{Time.now.localtime} for League(#{league_id}) ======"
    league = League.find_by_id(league_id)
    if league.present?
      if league.teams.count.zero?
        league.fetch_teams_and_their_matches
      else
        league.update_gws_and_fixtures
      end
      log.info "====== UpdateGwFixtureWorker Completed at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== UpdateGwFixtureWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
