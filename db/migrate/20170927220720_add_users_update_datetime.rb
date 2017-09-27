class AddUsersUpdateDatetime < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_update_at, :datetime
    add_column :users, :endurance_update_at, :datetime
  end
end
