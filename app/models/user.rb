class User < ApplicationRecord
  has_many :reports
  belongs_to :company
  
  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? find_by_telegram_id(message['from']['id']) : Company.our.users.create(telegram_id: message['from']['id'], username: message['from']['username'], game_name: message['text'].scan(/📯(.+) \(/)[0][0])
  end
end
