class GwPredictionCsvMailerWorker
  include Sidekiq::Worker

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting GwPredictionCsvMailerWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      csv_attachment = game_week.send_prediction_csv
      log.info "====== GwPredictionCsvMailerWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== GwPredictionCsvMailerWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
