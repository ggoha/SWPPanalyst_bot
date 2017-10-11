class Company < ApplicationRecord
  has_many :battles
  has_many :stocks
  has_many :users
  has_many :divisions

  SMILE = { '📯' => 1, '🤖' => 2, '⚡️' => 3, '☂️' => 4, '🎩' => 5 }.freeze

  def self.find_by(message)
    Company.find(SMILE[message.scan(/🎩|🤖|⚡️|☂️|📯/)[0]])
  end

  def self.our
    Company.find_by_title('📯Pied Piper')
  end

  def default_division
    divisions.first
  end
end
