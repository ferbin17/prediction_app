class MailGwScoreWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: false, backtrace: true

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting MailGwScoreWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      game_week.export_gw_scores
      game_week.export_total_scores
      game_week.send_scores_csv
      log.info "====== MailGwScoreWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======\n\n"
      league = game_week.league
      UpdateGwFixtureWorker.perform_at(Time.now.localtime + 10.minutes, league.id)
      log.info "====== Scheduled UpdateGwFixtureWorker at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== ExportGwScoreWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======\n\n"
    end
  end
end
