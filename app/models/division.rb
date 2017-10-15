class Division < ApplicationRecord
  has_many :users
  belongs_to :company, optional: true
  validates_uniqueness_of :telegram_id

  has_many :admins, through: :admin_divisions
  has_many :admin_divisions

  def admin?(user)
    admins.include?(user)
  end

  def self.create_from(message, user)
    create(telegram_id: message['chat']['id'], title: message['chat']['title'], company_id: user.company_id)
  end

  def self.find_or_default(message)
    find_by_telegram_id(message['chat']['id']) ? find_by_telegram_id(message['chat']['id']) : Company.findby(message).default_division
  end

  def self.find_or_create(message, user)
    find_by_telegram_id(message['chat']['id']) ? find_by_telegram_id(message['chat']['id']) : create_from(message)
  end
end
