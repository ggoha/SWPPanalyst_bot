class AddUsersRage < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :rage, :integer, default: 0
    add_column :companies, :sadness, :integer
    sadness = [3,3,3,3,1]
    Company.all.each_with_index do |c, i|
      c.update_attributes(sadness: sadness[i])
    end
  end
end
