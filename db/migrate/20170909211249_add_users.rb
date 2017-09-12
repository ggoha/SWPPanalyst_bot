class AddUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :game_name, null: false
      t.string :telegram_id
      t.integer :company_id
    end
  end
end
