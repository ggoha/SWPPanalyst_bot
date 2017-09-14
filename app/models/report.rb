class Report < ApplicationRecord
  belongs_to :user
  belongs_to :battle

  validates_uniqueness_of :battle_id, :scope => :user_id
  scope :for_division, ->(division) { includes(:user).where('users.division_id' => division.id) }
end
