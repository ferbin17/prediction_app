class PredictionScore < ApplicationRecord
  belongs_to :fixture
  belongs_to :prediction
  validates_presence_of :scoreline, :winning_team_id 
  validate :repeated_prediction, on: [:create]
  validate :deadline_time
  
  def home_team
    fixture.home_team.show_name
  end
  
  def away_team
    fixture.away_team.show_name
  end
  
  def home_team_score
    scoreline.split("-")[0]
  end
  
  def away_team_score
    scoreline.split("-")[1]
  end
  
  private
    def repeated_prediction
      if PredictionScore.exists?(fixture_id: self.fixture_id, prediction_id: self.prediction_id)
        self.errors.add(:base, :match_already_predicted)
      end
    end
    
    def deadline_time
      if Time.at(self.prediction.game_week.deadline_time_epoch) < Time.now.localtime && self.changed.include?("scoreline", "winning_team_id")
        self.errors.add(:base, :deadline_time_passes)
      end
    end
end
