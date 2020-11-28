class UpdateGwFixtureWorker
  include Sidekiq::Worker

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
      ExportGwPredictionWorker.perform_at(Time.now.localtime + 10.minutes, league.id)
      log.info "====== Scheduled ExportGwPredictionWorker at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== UpdateGwFixtureWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
