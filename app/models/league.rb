require 'net/http'
class League < ApplicationRecord
  has_many :teams
  has_many :game_weeks
  validates_presence_of :name, :code
  
  REJECT_COLUMNS = ["id", "created_at", "updated_at"]
  
  def current_game_week
    self.game_weeks.where("(finished = false AND is_current = true) OR (is_next = true AND deadline_time_epoch >= #{Time.now.localtime.to_i})").try(:first)
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
        team = self.teams.find_or_create_by(slug: team_response["id"])
        team.update(create_params("team", team_response))
      end
    end
  end
  
  def fetch_gameweeks
    uri = URI('https://fantasy.premierleague.com/api/bootstrap-static/')
    result = http_moved_handler(uri)
    if result.present? && result["events"]
      result["events"].each do |event|
        game_week = self.game_weeks.find_or_create_by(slug: event["id"])
        game_week.update(create_params("game_week", event))
      end
    end
  end
  
  def fetch_league_fixtures
    self.game_weeks.each do |game_week|
      game_week.fetch_fixtures
    end
  end
  
  private
    def create_params(model, response)
      params = {}
      modelize = model.camelize.constantize
      (modelize.column_names - REJECT_COLUMNS).each do |key|
        params[key.to_sym] = response[key] if response[key].present?
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
