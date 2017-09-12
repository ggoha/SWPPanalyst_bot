class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.integer :company_id
      t.integer :price
      t.datetime :at
    end
  end
end
