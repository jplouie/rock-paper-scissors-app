class AddWinCountToTournies < ActiveRecord::Migration
  def change
    add_column :tournies, :wins, :integer
  end
end
