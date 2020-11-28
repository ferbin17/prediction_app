class CreateLeagueTables < ActiveRecord::Migration[6.0]
  def change
    create_table :league_tables do |t|
      t.integer :league_id
      t.integer :team_id
      t.integer :matches
      t.integer :points
      t.integer :wins
      t.integer :draws
      t.integer :lose
      t.integer :goals_s
      t.integer :goals_a
      t.integer :goals_d
      t.timestamps
    end
  end
end
