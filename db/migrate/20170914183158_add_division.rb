class AddDivision < ActiveRecord::Migration[5.0]
  def change
    create_table :divisions do |t|
      t.string :title, null: false
      t.string :telegram_id
      t.integer :company_id
    end
    add_column :users, :division_id, :integer
    division = Company.our.divisions.create(title: 'Отдел Маркетинга', telegram_id: Rails.application.secrets['telegram']['om'])
    division.users << User.all
  end
end
