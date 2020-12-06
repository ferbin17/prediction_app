class MatchFixtureUpdateSchedulerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app#, retry: 0, backtrace: true

  def perform(game_week_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting MatchFixtureUpdateSchedulerWorker at #{Time.now.localtime} for GameWeek(#{game_week_id}) ======"
    game_week = GameWeek.find_by_id(game_week_id)
    if game_week.present?
      game_week.fixtures.each do |fixture|
        UpdateFixtureWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 2.hours + 15.minutes, game_week.id)
        log.info "====== Scheduled UpdateFixtureWorker at #{Time.now.localtime} for Fixture(#{fixture.id}) #{fixture.show_match} ======"
        
        FixtureScoreCalulatorWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 2.hours + 30.minutes, fixture.id)
        log.info "====== Scheduled FixtureScoreCalulatorWorker at #{Time.now.localtime} for Fixture(#{fixture.id}) #{fixture.show_match} ======"
        
        if game_week.last_match.id == fixture.id
          GwScoreCalulatorWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 3.hours, game_week.id)
          log.info "====== Scheduled GwScoreCalulatorWorker at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
          
          MailGwScoreWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 4.hours, game_week.id)
          log.info "====== Scheduled MailGwScoreWorker at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
        end
      end
      log.info "====== MatchFixtureUpdateSchedulerWorker Completed at #{Time.now.localtime} for GameWeek(#{game_week.id}) #{game_week.name} ======"
    else
      log.info "====== MatchFixtureUpdateSchedulerWorker Failed at #{Time.now.localtime} for GameWeek(#{game_week_id}) - Not Found ======"
    end
  end
end
