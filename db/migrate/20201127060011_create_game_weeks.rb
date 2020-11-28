class CreateGameWeeks < ActiveRecord::Migration[6.0]
  def change
    create_table :game_weeks do |t|
      t.string :name
      t.datetime :deadline_time
      t.bigint :deadline_time_epoch
      t.boolean :finished, default: false
      t.boolean :is_previous, default: false
      t.boolean :is_current, default: false
      t.boolean :is_next, default: false
      t.integer :league_id
      t.integer :slug
      t.boolean :gw_score_calculated, default: false
      t.timestamps
    end
  end
end
