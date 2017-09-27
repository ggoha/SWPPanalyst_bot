require "#{Rails.root}/app/helpers/application_helper.rb"
include ApplicationHelper

namespace :group do
  def remind
    bot = Telegram.bots[:division]
    Division.where(autopin: true).each do |d|
      message = bot.send_message chat_id: d.telegram_id, text: d.message
      bot.pin_chat_message(chat_id: d.telegram_id, message_id: message['result']['message_id'])
    end
  end

  def current_situation
    bot = Telegram.bots[:division]
    Division.all.each do |d|
      bot.send_message chat_id: d.telegram_id, text: current_situation(Company.all)
    end
  end

  def mvp
    bot = Telegram.bots[:division]
    Division.all.each do |d|
      next unless d.company
      message = mvp(d.company.battles.last.reports.for_division(d))
      bot.send_message chat_id: d.telegram_id, text: message if message
    end
  end

  desc 'Все сообщения перед битвой'
  task before_battle: :environment do
    mvp
    current_situation
    remind
  end
end
