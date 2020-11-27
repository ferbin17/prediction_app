class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :short_name
      t.integer :league_id
      t.integer :slug
      t.timestamps
    end
  end
end
