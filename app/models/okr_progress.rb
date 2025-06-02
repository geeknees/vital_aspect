class OkrProgress < ApplicationRecord
  belongs_to :okr

  validates :progress_note, presence: true, length: { maximum: 2000 }
  validates :completion_percentage, presence: true, 
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :reported_at, presence: true

  scope :recent, -> { order(reported_at: :desc) }
  scope :for_period, ->(start_date, end_date) { where(reported_at: start_date..end_date) }

  def self.latest_for_okr(okr)
    where(okr: okr).order(reported_at: :desc).first
  end
end
