class User < ApplicationRecord
  has_many :reports
  belongs_to :company
  belongs_to :division
  validates_uniqueness_of :telegram_id

  SMILE = { '📯' => 1, '🤖' => 2, '⚡️' => 3, '☂️' => 4, '🎩' => 5 }

  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? find_by_telegram_id(message['from']['id']) : Division.find_by_telegram_id(message['chat']['id'])
                                                                                            .users.create(telegram_id: message['from']['id'], 
                                                                                                          company_id: SMILE[message['text'][0]], 
                                                                                                          username: message['from']['username'], 
                                                                                                          game_name: message['text'].scan(/📯(.+) \(/)[0][0])
  end
end
