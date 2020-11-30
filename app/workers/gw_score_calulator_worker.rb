class GwScoreCalulatorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: 0, backtrace: true

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting GwScoreCalulatorWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      game_week.calculate_gw_scores
      log.info "====== GwScoreCalulatorWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== GwScoreCalulatorWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
