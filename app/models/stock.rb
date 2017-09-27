class Stock < ApplicationRecord
  belongs_to :company

  validates_uniqueness_of :name, scope: :company_id

  scope :week, -> { where(at: (Time.now - 1.week)..Time.now) }
  scope :day, -> { where(at: (Time.now - 1.day)..Time.now) }
  default_scope { order(:at) }
end
