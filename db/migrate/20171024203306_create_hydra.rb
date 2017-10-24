class CreateHydra < ActiveRecord::Migration[5.0]
  def change
    create_table :monsters do |t|
      t.string :title
      t.integer :hp2
      t.integer :hp3
      t.integer :hp4
      t.integer :hp5
    end
    add_column :users, :halloween_status, :string, default: :inactive
  end
end
