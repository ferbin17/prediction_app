class ExportGwScoreWorker
  include Sidekiq::Worker

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting ExportGwScoreWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      csv_attachment1 = game_week.export_gw_scores
      csv_attachment2 = game_week.export_total_scores
      result = csv_attachment1 && csv_attachment2 ? "Completed" : "Failed"
      log.info "====== ExportGwScoreWorker #{result} at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
      GwScoresCsvMailerWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 5.hours, game_week.id)
      log.info "====== Scheduled GwScoresCsvMailerWorker at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== ExportGwScoreWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
