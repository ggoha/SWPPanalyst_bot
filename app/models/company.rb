class Company < ApplicationRecord
  has_many :battles
  has_many :stocks
  has_many :users
  has_many :divisions

  def self.our
    Company.find_by_title('📯Pied Piper')
  end
end
