class CreateBattles < ActiveRecord::Migration[5.0]
  def change
    create_table :battles do |t|
      t.integer :company_id
      t.integer :score
      t.integer :summary_score
      t.boolean :result
      t.datetime :at
    end
  end
end
