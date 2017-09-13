class Battle < ApplicationRecord
  belongs_to :company
  has_many :reports
  before_save :update_summary_score

  validates_uniqueness_of :name, :scope => :company_id

  scope :week, -> { where(at: (Time.now - 1.week)..Time.now) }
  scope :day, -> { where(at: (Time.now - 1.day)..Time.now) }
  default_scope { order(:at) }
  
  def update_summary_score
    self.summary_score = company.score + score
    company.update_attributes(score: self.summary_score)
  end

  def add_reports
    reports << Report.find_by_battle_name(at.strftime("%Y-%M-%D-%H"))
  end

  def losses
    money.positive? ? 0 : -money
  end
end
