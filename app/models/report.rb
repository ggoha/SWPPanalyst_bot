class Report < ApplicationRecord
  belongs_to :user
  belongs_to :battle

  validates_uniqueness_of :battle_id, scope: :user_id
  after_save :update_sadness

  scope :for_division, ->(division) { includes(:user).where('users.division_id' => division.id) }
  scope :for_broked_company, ->(id) { where(broked_company_id: id) }
  scope :day, -> { includes(:battle).where(battles: { at: Time.now.midnight..Time.now }) }

  def update_sadness
    user.update_attributes(rage: score.zero? || score.nil? ? [user.rage + 1, 10].min : 0)
  end
end
