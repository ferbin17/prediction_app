class Fixture < ApplicationRecord
  belongs_to :game_week
  belongs_to :home_team, class_name: "Team", foreign_key: :home_team_id
  belongs_to :away_team, class_name: "Team", foreign_key: :away_team_id
  has_many :prediction_scores, dependent: :destroy
  validates_presence_of :kickoff_time, :away_team_id, :home_team_id, :slug
  after_save :set_kickoff_time_epoch, if: Proc.new{|fixture| fixture.kickoff_time_epoch.nil? or fixture.kickoff_time_changed?}
  
  def show_match
    "#{home_team.show_name} vs #{away_team.show_name}"
  end

  def scoreline
    "#{home_team_score}-#{away_team_score}"
  end
  
  def winning_team_id
    team_id = home_team_score > away_team_score ? home_team.id : away_team.id
    team_id = 0 if home_team_score == away_team_score
    team_id
  end
  
  def calculate_fixture_score
    unless score_calulated
      fixture_predicion_scores = prediction_scores
      fixture_predicion_scores.each do |fixture_predicion_score|
        score = 0
        score += 1 if scoreline == fixture_predicion_score.scoreline
        score += 1 if winning_team_id == fixture_predicion_score.winning_team_id
        fixture_predicion_score.update(calculated_score: score, score_calulated: true)
      end
    end
  end
  
  def to_response
    params = {"started" => (finished ? true : false), "minutes" => 0, 
      "team_h" => home_team.id, "team_a" => away_team.id, "finished" => finished,
      "kickoff_time" => kickoff_time, "team_h_score" => (finished ? home_team_score : ""),
      "team_a_score" => (finished ? away_team_score : "")}
    params
  end
  
  private
    def set_kickoff_time_epoch
      self.update(kickoff_time_epoch: self.kickoff_time.utc.to_i)
    end
end
