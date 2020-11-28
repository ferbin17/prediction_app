class GwScoresCsvMailerWorker
  include Sidekiq::Worker

  def perform(*args)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting GwScoresCsvMailerWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      game_week.send_scores_csv
      log.info "====== GwScoresCsvMailerWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== GwScoresCsvMailerWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
    log.info "====== Completed daily_job_runner at #{Time.now.localtime} ======\n\n"
  end
end
