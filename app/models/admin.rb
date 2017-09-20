class Admin < User
  has_many :moderated_divisions, through: :admin_divisions, source: :division
  has_many :admin_divisions
end
