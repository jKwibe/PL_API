class AddPlayerUidIndexToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_index :players, :player_uid
  end
end
