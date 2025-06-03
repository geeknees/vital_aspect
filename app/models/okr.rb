class Okr < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :key_results, dependent: :destroy
  has_many :okr_progresses, dependent: :destroy

  accepts_nested_attributes_for :key_results,
                                allow_destroy: true,
                                reject_if: :all_blank

  enum :status, {
    draft: 0,       # ドラフト
    active: 1,      # アクティブ
    completed: 2,   # 完了
    cancelled: 3    # キャンセル
  }

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :upcoming, -> { where("start_date > ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }

  def progress_percentage
    return 0 if key_results.empty?

    total_progress = key_results.sum do |kr|
      (kr.current_value / kr.target_value * 100).clamp(0, 100)
    end

    (total_progress / key_results.count).round(2)
  end

  def is_current?
    start_date <= Date.current && end_date >= Date.current
  end

  def days_remaining
    return 0 if end_date < Date.current
    (end_date - Date.current).to_i
  end

  def latest_progress
    okr_progresses.order(reported_at: :desc).first
  end
  
  def overall_progress
    latest = latest_progress
    if latest && latest.completion_percentage.present?
      latest.completion_percentage
    else
      progress_percentage
    end
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date <= start_date
      errors.add(:end_date, :must_be_after_start_date)
    end
  end
end
