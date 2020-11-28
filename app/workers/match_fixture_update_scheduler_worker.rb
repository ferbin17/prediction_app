class MatchFixtureUpdateSchedulerWorker
  include Sidekiq::Worker

  def perform(league_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting MatchFixtureUpdateSchedulerWorker at #{Time.now.localtime} for League(#{league_id}) ======"
    league = League.find_by_id(league_id)
    if league.present?
      current_gw = league.current_game_week
      current_gw.fixtures.each do |fixture|
        UpdateFixtureWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 2.hours, current_gw.id)
        log.info "====== Scheduled UpdateFixtureWorker at #{Time.now.localtime} for GameWeek(#{current_gw.id}) #{current_gw.name} ======"
        FixtureScoreCalulatorWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 3.hours, fixture.id)
        log.info "====== Scheduled FixtureScoreCalulatorWorker at #{Time.now.localtime} for Fixture(#{fixture.id}) #{fixture.show_match} ======"
        if current_gw.current_gw.id == fixture.id
          GwScoreCalulatorWorker.perform_at(Time.at(fixture.kickoff_time_epoch).localtime + 4.hours, current_gw.id)
          log.info "====== Scheduled GwScoreCalulatorWorker at #{Time.now.localtime} for GameWeek(#{current_gw.id}) #{current_gw.show_match} ======"
        end
      end
      log.info "====== MatchFixtureUpdateSchedulerWorker Completed at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
    else
      log.info "====== MatchFixtureUpdateSchedulerWorker Failed at #{Time.now.localtime} for League(#{league_id}) - Not Found ======"
    end
  end
end
