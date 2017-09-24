require "#{Rails.root}/app/models/concerns/showing.rb"
include Showing
require "#{Rails.root}/app/helpers/application_helper.rb"
include ApplicationHelper

namespace :group do
  desc 'Пиннит сообщение об еде'
  task remind: :environment do
    bot = Telegram.bots[:division]
    Division.where(autopin: true).each do |d|
      message = bot.send_message chat_id: d.telegram_id, text: d.message
      bot.pin_chat_message(chat_id: d.telegram_id, message_id: message['result']['message_id'])
    end
  end
  desc 'Cообщение о ситуации'
  task current_situation: :environment do
    bot = Telegram.bots[:division]
    Division.all.each do |d|
      bot.send_message chat_id: d.telegram_id, text: current_situation(Company.all)
    end
  end
  desc 'MVP'
  task mvp: :environment do
    bot = Telegram.bots[:division]
    Division.all.each do |d|
      message = mvp(d.company.battles.last.reports)
      bot.send_message chat_id: d.telegram_id, text: message if message
    end
  end
end
