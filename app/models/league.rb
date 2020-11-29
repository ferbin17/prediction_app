require 'net/http'
class League < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :game_weeks, dependent: :destroy
  has_many :league_tables, dependent: :destroy
  validates_presence_of :name, :code
  
  REJECT_COLUMNS = ["id", "created_at", "updated_at"]
  
  def current_game_week
    game_weeks.where("(finished = false AND is_current = true) OR (is_next = true AND deadline_time_epoch >= #{Time.now.localtime.to_i})").try(:first)
  end
  
  def last_game_week
    game_weeks.find_by(is_previous: true)
  end
  
  def previous_gw(gw_id)
    game_week = game_weeks.find_by_id(gw_id)
    prev = game_weeks.where("deadline_time_epoch < #{game_week.deadline_time_epoch}").order("deadline_time_epoch desc").limit(1).try(:first) if game_week.present?
    prev
  end
  
  def next_gw(gw_id)
    game_week = game_weeks.find_by_id(gw_id)
    nxt = game_weeks.where("deadline_time_epoch > #{game_week.deadline_time_epoch}").order("deadline_time_epoch asc").limit(1).try(:first) if game_week.present?
    nxt
  end
  
  def change_game_week
    current_gw = game_weeks.find_by(is_current: true)
    if current_gw && Time.now.localtime > (Time.at(current_gw.last_match.kickoff_time_epoch) + 2.hours)
      current_gw.update(finished: true)
    end
    finished_current_gw = game_weeks.find_by(is_current: true, finished: true)
    if finished_current_gw
      next_game_week = game_weeks.find_by(is_next: true)
      if next_game_week
        if next_game_week.update(is_next: false, is_current: true)
          game_weeks.update(is_previous: false)
          finished_current_gw.update(is_previous: true)
          new_next_game_week = game_weeks.where("deadline_time_epoch > #{next_game_week.deadline_time_epoch}").limit(1).try(:first)
          new_next_game_week.update(is_next: true) if new_next_game_week.present?
        end
      end
    end
    log = Logger.new('log/daily_job_runner.log')
    UpdateGwFixtureWorker.perform_at(Time.now.localtime + 5.minutes, self.id)
    log.info "====== Scheduled UpdateGwFixtureWorker at #{Time.now.localtime} for League(#{self.id}) #{self.name} ======"
  end
  
  def update_league_table
    teams.each(&:update_league_table)
  end
  
  def calculate_gws_score
    game_weeks.where(finished: true).each(&:calculate_gw_scores)
  end
  
  def gws_prediction_details
    results = {}
    game_weeks.where(finished: true).order("deadline_time_epoch asc").each do |game_week|
      results[game_week] = game_week.prediction_details
    end
    results
  end
  
  def update_gws_and_fixtures
    fetch_gameweeks
    fetch_league_fixtures
  end
  
  def fetch_teams_and_their_matches
    fetch_teams
    fetch_gameweeks
    fetch_league_fixtures
  end
  
  def fetch_teams
    uri = URI('https://fantasy.premierleague.com/api/bootstrap-static/')
    result = http_moved_handler(uri)
    if result.present? && result["teams"]
      result["teams"].each do |team_response|
        team = teams.find_or_create_by(slug: team_response["id"])
        team.update(create_params("team", team_response))
      end
    end
  end
  
  def fetch_gameweeks
    uri = URI('https://fantasy.premierleague.com/api/bootstrap-static/')
    result = http_moved_handler(uri)
    if result.present? && result["events"]
      result["events"].each do |event|
        game_week = game_weeks.find_or_create_by(slug: event["id"])
        game_week.update(create_params("game_week", event))
      end
    end
  end
  
  def fetch_league_fixtures
    game_weeks.each do |game_week|
      game_week.fetch_fixtures
    end
  end
  
  private
    def create_params(model, response)
      params = {}
      modelize = model.camelize.constantize
      (modelize.column_names - REJECT_COLUMNS).each do |key|
        params[key.to_sym] = response[key] unless response[key].nil?
      end
      params
    end
    
    def http_moved_handler(uri)
      begin
        response = Net::HTTP.get_response(uri)
        if response.code == "301"
          response = Net::HTTP.get_response(URI.parse("https//" + url.host + response['location']))
        end
        if response.code == "200"
          result = JSON.parse(response.body)
        end
        result
      rescue Exception => e
        log = Logger.new('log/http_logger.log')
        log.info "HTTP request failed. Reason: #{e.message} at #{Time.now}"
      end
    end
end
