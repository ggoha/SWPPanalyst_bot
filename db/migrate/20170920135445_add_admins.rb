class AddAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :type, :string, default: 'User'
    add_column :divisions, :message, :string, default: '15 минут до взлома, не забудьте поесть и слить деньги в акции' 
    create_table :admin_divisions do |t|
      t.integer :division_id
      t.integer :admin_id
    end
    bot = Telegram.bots[:division]
    Division.all.each do |d|
      result = bot.get_chat_administrators(chat_id: d.telegram_id)['result']
      result.each do |administrator|
        user = User.find_by_telegram_id(administrator['user']['id'].to_s)
        if user
          admin = user.update_attributes(type: 'Admin')
          admin.moderated_divisions << d
        end
      end
    end
  end
end
