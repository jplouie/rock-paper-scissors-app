class AddPlayerNumberToTournies < ActiveRecord::Migration
  def change
    add_column :tournies, :slot_number, :integer
  end
end
