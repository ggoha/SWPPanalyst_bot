class AddAnotherUsersParams < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :level, :integer
    add_column :users, :stars, :integer
    add_column :users, :endurance, :integer
    add_column :users, :experience, :integer  
  end
end
