class CreateAchivments < ActiveRecord::Migration[5.0]
  def change
    create_table :achivments do |t|
      t.string :title
      t.string :icon
      t.string :description
      t.float :percentage, default: 0
      t.boolean :public, default: true
    end
    create_table :user_achivments do |t|
      t.integer :achivment_id
      t.integer :user_id
    end
    add_column :battles, :raw, :text
  end
end
