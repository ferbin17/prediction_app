class UpdateFixtureWorker
  include Sidekiq::Worker

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting UpdateFixtureWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      csv_attachment = game_week.fetch_fixtures
      log.info "====== UpdateFixtureWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== UpdateFixtureWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
