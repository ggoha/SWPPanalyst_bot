class Achivment < ApplicationRecord
  has_many :users, through: :user_achivments
  has_many :user_achivments

  scope :no_obtain_for, ->(user) { Achivment.where(public: true) - user.achivments }

  def update_percentage
    update_attributes(percentage: users.count.to_f / User.count)
  end

  def show?
    percentage > 33
  end
end
