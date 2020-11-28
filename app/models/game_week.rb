require 'net/http'
class GameWeek < ApplicationRecord
  belongs_to :league
  has_many :fixtures, dependent: :destroy
  has_many :predictions, dependent: :destroy
  validates_presence_of :name, :deadline_time, :deadline_time_epoch, :slug
  validate :check_prediction_calculated, if: Proc.new{|game_week| game_week.gw_score_calculated_changed?}
  # validate :single_previous_current_next, if: Proc.new{|game_week| game_week.changed.include?("is_previous", "is_current", "is_next")}
  
  REJECT_COLUMNS = ["id", "created_at", "updated_at"]
  
  def calculate_gw_scores
    calculate_completed_fixure_score
    unless fixtures.where(finished: false).present?
      calculated_gw_prediction_score
    end
    unless predictions.where(gw_score_calulated: false).present?
      if self.update(gw_score_calculated: true)
        PredictionTable.update_table
      end
    end
  end
  
  def calculate_completed_fixure_score
    completed_fixtures = fixtures.where(finished: true)
    completed_fixtures.each(&:calculate_fixture_score)  
  end
  
  def calculated_gw_prediction_score
    gw_predictions = predictions
    gw_predictions.each do |gw_prediction|
      gw_prediction.calculate_score
    end
  end
  
  def prediction_details
    topper = predictions.order("calculated_gw_score desc").limit(1).try(:first)
    if topper.present?
      top_score = topper.calculated_gw_score
      topper = topper.user
    end
    {count: predictions.count, topper: topper, top_score: top_score}
  end
  
  def last_match
    fixtures.order("kickoff_time_epoch desc").limit(1).try(:first)
  end

  def fetch_fixtures
    uri = URI("https://fantasy.premierleague.com/api/fixtures/?event=#{self.slug}")
    result = http_moved_handler(uri)
    if result.present?
      result.each do |fixture_response|
        fixture = fixtures.find_or_create_by(slug: fixture_response["id"])
        fixture.update(create_fixture_params("fixture", fixture_response))
      end
    end
  end
  
  def export_prediction_csv
  end
  
  def send_prediction_csv
  end
  
  def export_gw_scores
  end
  
  def export_total_scores
  end
  
  def send_scores_csv
  end
  
  private
    def single_previous_current_next
      league = self.league
      # if 
        # league.exists?
    end
    
    def check_prediction_calculated
      if self.predictions.where(gw_score_calulated: false).present?
        self.errors.add(:base, :gw_predictions_not_calculated)
      end
    end
    
    def create_fixture_params(model, response)
      params = {}
      modelize = model.camelize.constantize
      (modelize.column_names - REJECT_COLUMNS).each do |key|
        params[key.to_sym] = response[key] unless response[key].nil?
      end
      league = self.league
      home_team = league.teams.find_by(slug: response["team_h"])
      away_team = league.teams.find_by(slug: response["team_a"])
      params = params.merge({home_team_score: response["team_h_score"].to_i,
        away_team_score: response["team_a_score"].to_i, game_week_id: self.id,
          home_team_id: home_team.try(:id), away_team_id: away_team.try(:id)})
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
