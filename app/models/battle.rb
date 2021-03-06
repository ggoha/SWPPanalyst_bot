class Battle < ApplicationRecord
  belongs_to :company
  has_many :reports
  before_save :update_summary_score
  after_save :update_sadness

  validates_uniqueness_of :name, scope: :company_id

  scope :ultima, -> { where(company_id: Company.our).last }
  scope :penultima, -> { where(company_id: Company.our).last(2)[0] }

  scope :week, -> { where(at: (Time.now - 1.week)..Time.now) }
  scope :yesterday, -> {where(at: (Time.now.midnight - 1.day)..Time.now.midnight) }
  scope :day, -> { where(at: (Time.now - 1.day)..Time.now) }
  default_scope { order(:at) }
  
  def update_summary_score
    self.summary_score = company.score + score
    company.update_attributes(score: summary_score)
  end

  def update_sadness
    company.update_attributes(sadness: result ? 0 : [company.sadness + 1, 5].min)
  end

  def losses
    money.positive? ? 0 : -money
  end
end
