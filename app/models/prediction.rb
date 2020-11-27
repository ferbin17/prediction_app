class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :game_week
  has_many :prediction_scores, dependent: :destroy
  validate :repeated_prediction, on: [:create]
  
  private
    def repeated_prediction
      if Prediction.exists?(user_id: self.user_id, game_week_id: self.game_week_id)
        self.errors.add(:base, :game_week_already_predicted)
      end
    end
end   
