class Company < ApplicationRecord
  has_many :battles
  has_many :stocks
end
