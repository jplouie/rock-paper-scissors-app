class RemovePasswordHashFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :password_hash, :string
  end
end
