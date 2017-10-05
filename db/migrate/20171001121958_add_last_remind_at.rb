class AddLastRemindAt < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_remind_at, :datetime, default: DateTime.now
  end
end
