class CreatePredictionTables < ActiveRecord::Migration[6.0]
  def change
    create_table :prediction_tables do |t|
      t.integer :user_id
      t.float :current_score
      t.float :last_gw_score
      t.integer :total_gw_predicted
      t.timestamps
    end
  end
end
