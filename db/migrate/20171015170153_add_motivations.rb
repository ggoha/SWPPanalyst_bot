class AddMotivations < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :motivation, :integer
  end
end
