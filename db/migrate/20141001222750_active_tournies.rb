class ActiveTournies < ActiveRecord::Migration
  def change
    create_table :actives do |t|
      t.string :status
    end
  end
end
