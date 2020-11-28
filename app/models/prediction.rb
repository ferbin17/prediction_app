class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :game_week
  has_many :prediction_scores, dependent: :destroy
  validate :repeated_prediction, on: [:create]
  validate :deadline_time, if: Proc.new{|prediction| prediction.game_week_id_changed? }
  validate :check_prediction_calculated, if: Proc.new{|prediction| prediction.gw_score_calulated_changed?}
  
  def calculate_score
    score = prediction_scores.sum(:calculated_score)
    self.update(calculated_gw_score: score, gw_score_calulated: true)
  end
  
  private
    def repeated_prediction
      if Prediction.exists?(user_id: self.user_id, game_week_id: self.game_week_id)
        self.errors.add(:base, :game_week_already_predicted)
      end
    end
    
    def deadline_time
      if Time.at(self.game_week.deadline_time_epoch) < Time.now.localtime
        self.errors.add(:base, :deadline_time_passes)
      end
    end
    
    def check_prediction_calculated
      if self.prediction_scores.where(score_calulated: false).present?
        self.errors.add(:base, :gw_predictions_not_calculated)
      end
    end
end   
