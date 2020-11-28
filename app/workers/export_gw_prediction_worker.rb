class ExportGwPredictionWorker
  include Sidekiq::Worker

  def perform(league_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting ExportGwPredictionWorker at #{Time.now.localtime} for League(#{league_id}) ======"
    league = League.find_by_id(league_id)
    if league.present?
      current_gw = league.current_game_week
      work = current_gw.export_prediction_csv
      result = work ? "Completed" : "Failed"
      log.info "====== ExportGwPredictionWorker #{result} at #{Time.now.localtime} for GameWeek(#{current_gw.id}) #{current_gw.name} ======"
      if work
        GwPredictionCsvMailerWorker.perform_at(Time.now.localtime + 10.minutes, current_gw.id)
        log.info "====== Scheduled GwPredictionCsvMailerWorker at #{Time.now.localtime} for GameWeek(#{current_gw.id}) #{current_gw.name} ======"
      end
    else
      log.info "====== ExportGwPredictionWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
