class CreatePredictionTables < ActiveRecord::Migration[6.0]
  def change
    create_table :prediction_tables do |t|
      t.integer :user_id
      t.float :current_score, default: 0.0
      t.float :last_gw_score, default: 0.0
      t.integer :total_gw_predicted, default: 0
      t.integer :total_gw_score_calculated, default: 0
      t.timestamps
    end
  end
end
