class FixtureScoreCalulatorWorker
  include Sidekiq::Worker
  sidekiq_options queue: :prediction_app, retry: false, backtrace: true

  def perform(fixture_id)
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting FixtureScoreCalulatorWorker at #{Time.now.localtime} for Fixture(#{fixture_id}) ======"
    fixture = Fixture.find_by_id(fixture_id)
    if fixture.present?
      fixture.calculate_fixture_score
      log.info "====== FixtureScoreCalulatorWorker Completed at #{Time.now.localtime} for Fixture(#{fixture.id}) #{fixture.show_match} ======"
    else
      log.info "====== FixtureScoreCalulatorWorker Failed at #{Time.now.localtime} for Fixture(#{fixture_id}) - Not Found ======"
    end
  end
end
