class CreateLeagues < ActiveRecord::Migration[6.0]
  def change
    create_table :leagues do |t|
      t.string :name
      t.string :code
      t.integer :no_of_teams
      t.integer :slug
      t.timestamps
    end
  end
end
