class PredictionScore < ApplicationRecord
  belongs_to :fixture
  belongs_to :prediction
  validates_presence_of :scoreline, :winning_team_id 
  validate :repeated_prediction, on: [:create]
  
  def home_team
    self.fixture.home_team.show_name
  end
  
  def away_team
    self.fixture.away_team.show_name
  end
  
  def home_team_score
    self.scoreline.split("-")[0]
  end
  
  def away_team_score
    self.scoreline.split("-")[1]
  end
  
  private
    def repeated_prediction
      if PredictionScore.exists?(fixture_id: self.fixture_id, prediction_id: self.prediction_id)
        self.errors.add(:base, :match_already_predicted)
      end
    end
end
