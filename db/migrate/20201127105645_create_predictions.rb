class CreatePredictions < ActiveRecord::Migration[6.0]
  def change
    create_table :predictions do |t|
      t.integer :user_id
      t.integer :game_week_id
      t.boolean :gw_score_calulated, default: false
      t.float :calculated_gw_score
      t.timestamps
    end
  end
end
