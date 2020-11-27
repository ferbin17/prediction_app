require 'net/http'
class GameWeek < ApplicationRecord
  belongs_to :league
  has_many :fixtures
  validates_presence_of :name, :deadline_time, :deadline_time_epoch
  
  REJECT_COLUMNS = ["id", "created_at", "updated_at"]

  def fetch_fixtures
    uri = URI("https://fantasy.premierleague.com/api/fixtures/?event=#{self.slug}")
    result = http_moved_handler(uri)
    if result.present?
      result.each do |fixture_response|
        fixture = self.fixtures.find_or_create_by(slug: fixture_response["id"])
        league = self.league
        home_team = league.teams.find_by(slug: fixture_response["team_h"])
        away_team = league.teams.find_by(slug: fixture_response["team_a"])
        fixture.update(create_fixture_params("fixture", fixture_response).merge({game_week_id: self.id,
          home_team_id: home_team.try(:id), away_team_id: away_team.try(:id)}))
      end
    end
  end
  
  private
    def create_fixture_params(model, response)
      params = {}
      modelize = model.camelize.constantize
      (modelize.column_names - REJECT_COLUMNS).each do |key|
        params[key.to_sym] = response[key] if response[key].present?
      end
      params.merge({home_team_score: response["team_h_score"], away_team_score: response["team_h_score"]})
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
