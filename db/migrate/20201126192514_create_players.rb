class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.integer :team_id
      t.string :player_uid
      t.string :player_name

      t.timestamps
    end
  end
end
