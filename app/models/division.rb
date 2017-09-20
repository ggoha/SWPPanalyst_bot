class Division < ApplicationRecord
  has_many :users
  belongs_to :company, optional: true
  validates_uniqueness_of :telegram_id
  
  has_many :admins, through: :admin_divisions
  has_many :admin_divisions  

  def admin?(user)
    admins.include?(user)
  end

  def self.find_or_create(message)
    find_by_telegram_id(message['chat']['id']) ? find_by_telegram_id(message['chat']['id']) : Division.create(telegram_id: message['chat']['id'], title: message['chat']['title'])
  end
end
