class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :team_name
      t.string :team_logo
      t.string :team_name_short

      t.timestamps
    end
  end
end
