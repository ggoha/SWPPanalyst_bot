class AddReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.integer :broked_company_id
      t.integer :battle_id
      t.integer :kill
      t.integer :money
      t.integer :score
      t.boolean :active
    end
    add_column :battles, :name, :string
    add_column :stocks, :name, :string
  end
end
