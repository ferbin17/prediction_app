require 'net/http'
require 'csv'
class GameWeek < ApplicationRecord
  belongs_to :league
  has_many :fixtures, dependent: :destroy
  has_many :predictions, dependent: :destroy
  has_one_attached :prediction_attachment
  has_one_attached :score_attachment
  has_one_attached :total_score_attachment
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

  def fetch_fixtures(fixture_responses = nil)
    if fixture_responses.present?
      result = fixture_responses
    else
      uri = URI("https://fantasy.premierleague.com/api/fixtures/?event=#{self.slug}")
      result = http_moved_handler(uri)
    end
    if result.present?
      result.each do |fixture_response|
        fixture = fixtures.find_or_create_by(slug: fixture_response["id"])
        fixture.update(create_fixture_params("fixture", fixture_response))
      end
    end
    update_game_week_finished unless self.finished
  end
  
  def update_game_week_finished
    if Time.now.localtime >= (Time.at(last_match.kickoff_time_epoch) + 2.hours)
      self.update(finished: true)
    end
  end
  
  def export_prediction_csv
    file_name = "prediction_league_#{self.league_id}_gw_#{self.id}.csv"
    FileUtils.mkpath "#{Rails.root}/tmp/game_week_exports" unless File.exists? "#{Rails.root}/tmp/game_week_exports"
    file_path = "#{Rails.root}/tmp/game_week_exports/#{file_name}"
    headers = ["username", "game_week", "fixture", "scoreline", "winning_team"]
    CSV.open(file_path, 'w', write_headers: true, headers: headers) do |writer|
      predictions.each do |prediction|
        prediction.prediction_scores.each do |prediction_score|
          prediction_score_fixture = prediction_score.fixture
          winning_team = (prediction_score_fixture.winning_team_id == 0 ? "Draw" : Team.find_by_id(prediction_score_fixture.winning_team_id))
          row = [prediction.user.username, prediction.game_week.name, prediction_score_fixture.show_match,
                 prediction_score_fixture.scoreline, (winning_team.class == Team ? winning_team.show_name : winning_team)]
          writer << row
        end
      end
    end
    file = File.open("#{file_path}")
    if file
      self.prediction_attachment.destroy if self.prediction_attachment.present?
      if self.prediction_attachment.attach(io: File.open(file_path), 
        filename: file_name)
        begin
          FileUtils.rm file.path
        rescue
        end
      end
    end
  end
  
  def send_prediction_csv
    if self.prediction_attachment.present?
      file = {name: prediction_attachment.filename.to_s, path: attachment_path("prediction_attachment")}
      ["ferbin17@gmail.com"].each do |email_id|
        CsvMailer.with(email_id: email_id, file: file,
          game_week_name: name).send_prediction_attachment.deliver_now
      end
    end
  end
  
  def export_gw_scores
    file_name = "score_league_#{self.league_id}_gw_#{self.id}.csv"
    FileUtils.mkpath "#{Rails.root}/tmp/game_week_exports" unless File.exists? "#{Rails.root}/tmp/game_week_exports"
    file_path = "#{Rails.root}/tmp/game_week_exports/#{file_name}"
    headers = ["username", "game_week", "calculated_gw_score", "fixture", "scoreline", "winning_team", "calculated_score"]
    CSV.open(file_path, 'w', write_headers: true, headers: headers) do |writer|
      predictions.each do |prediction|
        prediction.prediction_scores.each do |prediction_score|
          prediction_score_fixture = prediction_score.fixture
          winning_team = (prediction_score_fixture.winning_team_id == 0 ? "Draw" : Team.find_by_id(prediction_score_fixture.winning_team_id))
          row = [prediction.user.username, prediction.game_week.name, prediction.calculated_gw_score, 
                 prediction_score_fixture.show_match, prediction_score_fixture.scoreline,
                 (winning_team.class == Team ? winning_team.show_name : winning_team),
                 prediction_score_fixture.calculated_score]
          writer << row
        end
      end
    end
    file = File.open("#{file_path}")
    if file
      self.score_attachment.destroy if self.score_attachment.present?
      if self.score_attachment.attach(io: File.open(file_path), 
        filename: file_name)
        begin
          FileUtils.rm file.path
        rescue
        end
      end
    end
  end
  
  def export_total_scores
    file_name = "total_score_league_#{self.league_id}_gw_#{self.id}.csv"
    FileUtils.mkpath "#{Rails.root}/tmp/game_week_exports" unless File.exists? "#{Rails.root}/tmp/game_week_exports"
    file_path = "#{Rails.root}/tmp/game_week_exports/#{file_name}"
    headers = ["username", "game_week", "current_score", "total_gw_predicted", "total_gw_score_calculated"]
    CSV.open(file_path, 'w', write_headers: true, headers: headers) do |writer|
      PredictionTable.all.each do |prediction_table|
        row = [prediction_table.user.username, self.name, prediction_table.current_score,
              prediction_table.total_gw_predicted, prediction_table.total_gw_score_calculated]
        writer << row
      end
    end
    file = File.open("#{file_path}")
    if file
      self.total_score_attachment.destroy if self.total_score_attachment.present?
      if self.total_score_attachment.attach(io: File.open(file_path), 
        filename: file_name)
        begin
          FileUtils.rm file.path
        rescue

        end
      end
    end
  end
  
  def send_scores_csv
    if self.prediction_attachment.present?
      files = [{name: score_attachment.filename.to_s, path: attachment_path("score_attachment")},
              {name: total_score_attachment.filename.to_s, path: attachment_path("total_score_attachment")}]
      ["ferbin17@gmail.com"].each do |email_id|
        CsvMailer.with(email_id: email_id, files: files,
          game_week_name: name).send_score_attachments.deliver_now
      end
    end
  end
  
  def attachment_path(attachment)
    ActiveStorage::Blob.service.path_for(self.send("#{attachment}").key)
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
      params[:finished] = response["finished_provisional"]
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
