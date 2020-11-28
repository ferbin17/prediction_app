class PredictionTable < ApplicationRecord
  belongs_to :user
  
  def self.update_table
    User.active.where(is_admin: false).each do |user|
      predict_table = user.prediction_table
      predict_table = user.build_prediction_table unless predict_table.present?
      calculated_predictions = user.predictions.where(gw_score_calulated: true)
      # Calculate last gw score
      predict_table.update(current_score: calculated_predictions.sum(:calculated_gw_score),
        last_gw_score: 0, total_gw_predicted: user.predictions.count,
        total_gw_score_calculated: calculated_predictions.count)
    end
  end
end
