class User < ApplicationRecord
  has_many :reports
  
  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? user : User.create(telegram_id: message['from']['id'])
  end
end
