class AddMoney < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :money, :integer
  end
end
