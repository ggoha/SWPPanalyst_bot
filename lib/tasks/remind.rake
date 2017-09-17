namespace :group do
  desc "Пиннит сообщение об еде"
  task remind: :environment do
    bot = Telegram.bots[:division]
    Division.where(autopin: true).each do |d|
      message = bot.send_message chat_id: d.telegram_id, text: '15 минут до взлома, не забудьте поесть и слить деньги в акции'
      bot.pin_chat_message(chat_id: d.telegram_id, message_id: message['result']['message_id'])
    end
  end
end
