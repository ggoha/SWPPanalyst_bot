class User < ApplicationRecord
  has_many :reports
  belongs_to :company
  belongs_to :division
  validates_uniqueness_of :telegram_id
  before_create :update_last_remind_at

  SMILE = { '📯' => 1, '🤖' => 2, '⚡️' => 3, '☂️' => 4, '🎩' => 5 }.freeze

  def admin?
    type == 'Admin'
  end

  def move(division_id = nil)
    update_attributes(division_id: division_id)
  end

  def reward_mvp
    update_attributes(mvp: mvp + 1)
  end

  def update_endurance(endurance)
    update_attributes(endurance: endurance, endurance_update_at: DateTime.now)
  end

  def update_profile(hash)
    update_attributes(hash.merge(profile_update_at: DateTime.now, last_remind_at: DateTime.now))
  end

  def update_last_remind_at
    self.last_remind_at = DateTime.now
  end

  def self.create_from(message)
    Division.find_by_telegram_id(message['chat']['id'])
            .users.create(telegram_id: message['from']['id'],
                          company_id: SMILE[message['text'][0]],
                          username: message['from']['username'],
                          game_name: message['text'].scan(/📯(.+) \(/)[0][0])
  end

  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? find_by_telegram_id(message['from']['id']) : create_from(message)
  end
end
