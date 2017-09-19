class Report < ApplicationRecord
  belongs_to :user
  belongs_to :battle

  validates_uniqueness_of :battle_id, :scope => :user_id
  scope :for_division, ->(division) { includes(:user).where('users.division_id' => division.id) }
  after_save :update_sadness

  def update_sadness
    user.update_attributes(rage: (score==0 or score==nil) ? [user.rage+1, 10].min : 0)
  end
end
