class User < ApplicationRecord
  include Achivmed

  has_many :reports
  belongs_to :company
  belongs_to :division
  has_many :achivments, through: :user_achivments
  has_many :user_achivments

  validates_uniqueness_of :telegram_id
  before_create :update_last_remind_at

  SMILE = { '📯' => 1, '🤖' => 2, '⚡️' => 3, '☂️' => 4, '🎩' => 5 }.freeze

  def admin?
    type == 'Admin'
  end

  def move(division_id = nil)
    if division_id
      update_attributes(division_id: division_id)
    else
      update_attributes(division_id: company.default_division.id)
    end
  end

  def reward_mvp
    update_attributes(mvp: mvp + 1)
    achivment = Achivment.find_by_title('MVP')
    add_achivment(achivment) unless achivments.include? achivment
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
    d = Division.find_or_default(message)
    user = d.users.create(telegram_id: message['from']['id'],
                          company_id: d.company_id,
                          username: message['from']['username'],
                          game_name: message['text'](/(🎩|🤖|⚡️|☂️|📯)(.+) \(/)[0][1])
    Achivment.all.each { |a| a.update_percentage }
    user
  end

  def self.find_or_create(message)
    find_by_telegram_id(message['from']['id']) ? find_by_telegram_id(message['from']['id']) : create_from(message)
  end
end
