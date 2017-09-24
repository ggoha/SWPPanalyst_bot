class AddMvp < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mvp, :integer, default: 0, nil: false
  end
end
