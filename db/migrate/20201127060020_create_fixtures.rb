class CreateFixtures < ActiveRecord::Migration[6.0]
  def change
    create_table :fixtures do |t|
      t.integer :game_week_id
      t.boolean :finished, default: false
      t.datetime :kickoff_time
      t.bigint :kickoff_time_epoch
      t.boolean :started, default: false
      t.integer :away_team_id
      t.integer :away_team_score, default: 0
      t.integer :home_team_id
      t.integer :home_team_score, default: 0
      t.integer :slug
      t.timestamps
    end
  end
end
