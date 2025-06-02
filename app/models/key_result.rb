class KeyResult < ApplicationRecord
  belongs_to :okr

  enum :status, {
    not_started: 0, # 未開始
    in_progress: 1, # 進行中
    completed: 2,   # 完了
    at_risk: 3      # リスク
  }

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 1000 }
  validates :target_value, presence: true, numericality: { greater_than: 0 }
  validates :current_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true, length: { maximum: 50 }

  def progress_percentage
    return 0 if target_value.zero?
    ((current_value / target_value) * 100).clamp(0, 100).round(2)
  end

  def is_completed?
    current_value >= target_value
  end

  def remaining_value
    [target_value - current_value, 0].max
  end

  def update_status_based_on_progress
    percentage = progress_percentage
    
    self.status = case percentage
                  when 0
                    :not_started
                  when 1...100
                    :in_progress
                  when 100
                    :completed
                  else
                    :in_progress
                  end
  end
end
