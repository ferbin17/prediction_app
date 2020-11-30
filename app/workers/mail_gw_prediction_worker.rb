class MailGwPredictionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: false, backtrace: true

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting MailGwPredictionWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      game_week.export_prediction_csv
      game_week.send_prediction_csv
      log.info "====== MailGwPredictionWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== MailGwPredictionWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
