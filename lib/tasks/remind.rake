require "#{Rails.root}/app/helpers/application_helper.rb"
include ApplicationHelper

def remind_task
  bot = Telegram.bots[:division]
  Division.where(autopin: true).each do |d|
    begin
      message = bot.send_message chat_id: d.telegram_id, text: d.message
      bot.pin_chat_message(chat_id: d.telegram_id, message_id: message['result']['message_id'])
      sleep(1)
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

def current_situation_task
  bot = Telegram.bots[:division]
  Division.all.each do |d|
    next unless d.telegram_id
    begin
      bot.send_message chat_id: d.telegram_id, text: current_situation(Company.all)
      sleep(1)
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

def mvp_task
  bot = Telegram.bots[:division]
  Division.all.each do |d|
    next unless d.company
    next unless d.telegram_id
    message = mvp(d.company.battles.last.reports.for_division(d))
    begin
      bot.send_message chat_id: d.telegram_id, text: message if message && !message.empty?
      sleep(1)
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

def admin_summary_task
  bot = Telegram.bots[:admin]
  chat_id = Rails.application.secrets['telegram']['admin']
  bot.send_message chat_id: chat_id, text: company_summary_report(Company.our), parse_mode: 'Markdown'
end

def update_profile_task
  bot = Telegram.bots[:division]
  text = 'Ты не обновлял профиль более 3-x дней, нам нужны актуальные данные, пожалуйста, перешли мне свой профиль'
  User.where('last_remind_at < ?', DateTime.now - 3.day).each do |user|
    user.update_attributes(last_remind_at: DateTime.now)
    begin
      sleep(10)
      bot.send_message chat_id: user.telegram_id, text: text
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

def after_day_task
  bot = Telegram.bots[:division]
  Division.where(autopin_nighty: true).each do |d|
    begin
      message = bot.send_message chat_id: d.telegram_id, text: d.nighty_message
      bot.pin_chat_message(chat_id: d.telegram_id, message_id: message['result']['message_id'])
    rescue StandardError => e
      Rails.logger.error e
    end
  end
end

def walk_task
  bot = Telegram.bots[:division]
  User.where(halloween_status: 'walk').each do |user|
    begin
      bot.send_message chat_id: user.telegram_id, text: Journey.event(user)
    rescue StandardError => e
      Rails.logger.error e
    end    
  end
end

namespace :group do
  desc 'Все сообщения перед битвой'
  task before_battle: :environment do
    mvp_task
    current_situation_task
    remind_task
    admin_summary_task
  end

  desc 'Быстрый результат после битвы'
  task after_battle: :environment do
    admin_summary_task
  end

  desc 'Напоминание о обновлении профилей'
  task update_profile: :environment do
    update_profile_task
  end

  desc 'Напоминание о конце дня'
  task after_day: :environment do
    after_day_task
  end

  task walk: :environment do
    walk_task
  end

  desc 'Результат боя с монстром'
  task halloween: :environment do
    ids = [1,3,6,7,9]
    m = current_situation_with_monster
    bot  = Telegram.bots[:division]
    Division.find(ids).each do |d|
        bot.send_message chat_id: d.telegram_id, text: m
    end
  end

  desc 'Результат боя с монстром'
  task regenerate: :environment do
    Monster.take.regenerate
    ids = [1,3,6,7,9]
    m = current_situation_with_monster
    bot  = Telegram.bots[:division]
    Division.find(ids).each do |d|
    	bot.send_message chat_id: d.telegram_id, text: m
    end
  end
end
