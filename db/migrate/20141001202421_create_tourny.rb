class CreateTourny < ActiveRecord::Migration
  def change
    create_table :tournies do |t|
      t.belongs_to :active
      t.belongs_to :player
      t.string :move
      t.string :status
      t.integer :round
    end
  end
end
