class AddUsersParams < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :practice, :integer
    add_column :users, :theory, :integer
    add_column :users, :cunning, :integer
    add_column :users, :wisdom, :integer
    add_column :reports, :buff, :float    
  end
end
