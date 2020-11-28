class ChangeGameWeekWorker
  include Sidekiq::Worker

  def perform(league_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting ChangeGameWeekWorker at #{Time.now.localtime} for League(#{league_id}) ======"
    league = League.find_by_id(league_id)
    if league.present?
      league.change_game_week
      log.info "====== ChangeGameWeekWorker Completed at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
      UpdateGwFixtureWorker.perform_at(Time.now.localtime + 10.minutes, league.id)
      log.info "====== Scheduled UpdateGwFixtureWorker at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
      MatchFixtureUpdateSchedulerWorker.perform_at(Time.now.localtime + 1.hours, league.id)
      log.info "====== Scheduled UpdateGwFixtureWorker at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== ChangeGameWeekWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
