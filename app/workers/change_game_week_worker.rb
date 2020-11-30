class ChangeGameWeekWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: 0, backtrace: true

  def perform(league_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting ChangeGameWeekWorker at #{Time.now.localtime} for League(#{league_id}) ======"
    league = League.find_by_id(league_id)
    if league.present?
      league.change_game_week
      log.info "====== ChangeGameWeekWorker Completed at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== ChangeGameWeekWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
