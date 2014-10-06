class AddGameOptionToActives < ActiveRecord::Migration
  def change
    add_column :actives, :option, :integer
  end
end
