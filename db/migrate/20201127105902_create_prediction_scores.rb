class CreatePredictionScores < ActiveRecord::Migration[6.0]
  def change
    create_table :prediction_scores do |t|
      t.integer :fixture_id
      t.string :scoreline
      t.integer :winning_team_id
      t.integer :prediction_id
      t.boolean :score_calulated, default: false
      t.float :calculated_score
      t.timestamps
    end
  end
end
