class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :title, null: false
      t.integer :score, default: 0
    end
    Company.create(title: 'Pied Piper')
    Company.create(title: 'Hooli')
    Company.create(title: 'Stark Ind.')
    Company.create(title: 'Umbrella')
    Company.create(title: 'Wayne Ent.')
  end 
end
