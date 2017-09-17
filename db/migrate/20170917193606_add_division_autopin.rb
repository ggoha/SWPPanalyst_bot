class AddDivisionAutopin < ActiveRecord::Migration[5.0]
  def change
    add_column :divisions, :autopin, :boolean, default: false, nil: false
    Division.find(2).update_attributes(autopin: true)
  end
end
