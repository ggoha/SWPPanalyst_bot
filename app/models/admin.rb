class Admin < User
  has_many :moderated_divisions, through: :admin_divisions, source: "Division"
  has_many :admin_divisions
end
