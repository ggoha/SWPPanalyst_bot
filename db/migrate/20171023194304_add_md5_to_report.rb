class AddMd5ToReport < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :md5, :string
  end
end
