namespace :prediction_app do
  desc "Start daily jobs"
  task daily_job_runner: :environment do
    log = Logger.new('log/daily_job_runner.log')
    log.info "====== Starting daily_job_runner at #{Time.now.localtime} ======"
    leagues = League.all
    leagues.each do |league|
      near_gameweeks = league.game_weeks.where("deadline_time_epoch <= #{(Time.now.localtime + 1.days).to_i} and deadline_time_epoch >= #{(Time.now.localtime).to_i}")
      near_gameweeks.each do |near_gameweek|
        time = Time.at(near_gameweek.deadline_time_epoch).localtime
        league = near_gameweek.league
        ChangeGameWeekWorker.perform_at(time, league.id)
        log.info "====== Scheduled ChangeGameWeekWorker at #{Time.now.localtime} for League(#{league.id}) #{league.name} ======"
        
        MailGwPredictionWorker.perform_at(time + 10.minutes, near_gameweek.id)
        log.info "====== Scheduled MailGwPredictionWorker at #{Time.now.localtime} for GameWeek(#{near_gameweek.id}) #{near_gameweek.name} ======"
        
        MatchFixtureUpdateSchedulerWorker.perform_at(time + 30.minutes, near_gameweek.id)
        log.info "====== Scheduled MatchFixtureUpdateSchedulerWorker at #{Time.now.localtime} for GameWeek(#{near_gameweek.id}) #{near_gameweek.name} ======"
      end
    end
    log.info "====== Completed daily_job_runner at #{Time.now.localtime} ======"
  end
end
