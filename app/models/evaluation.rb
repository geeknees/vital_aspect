class Evaluation < ApplicationRecord
  belongs_to :organization
  belongs_to :evaluator, class_name: "User"
  has_many :evaluation_participants, dependent: :destroy
  has_many :participants, through: :evaluation_participants, source: :user
  has_many :questions, dependent: :destroy
  has_many :responses, through: :questions

  enum :status, {
    draft: 0,        # 下書き
    active: 1,       # 実施中
    completed: 2,    # 完了
    cancelled: 3     # キャンセル
  }

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :due_date, presence: true
  validates :start_date, presence: true
  validate :due_date_after_start_date

  scope :current, -> { where(status: [ :draft, :active ]) }
  scope :for_organization, ->(org) { where(organization: org) }

  def can_edit?
    draft?
  end

  def can_start?
    draft? && questions.any? && evaluation_participants.any?
  end

  def can_complete?
    active? && all_required_responses_submitted?
  end

  def progress_percentage
    return 0 if evaluation_participants.empty?

    completed_count = completed_participants_count
    total_count = evaluation_participants.count

    (completed_count.to_f / total_count * 100).round
  end

  def completed_participants_count
    evaluation_participants.where(status: "completed").count
  end

  def created_by
    evaluator
  end

  private

  def due_date_after_start_date
    return unless start_date && due_date

    if due_date <= start_date
      errors.add(:due_date, "must be after start date")
    end
  end

  def all_required_responses_submitted?
    required_questions = questions.where(is_required: true)
    total_required = required_questions.count * evaluation_participants.count

    # Check for responses that have either content or score properly set
    submitted_required = responses.joins(:question)
                               .where(questions: { is_required: true })
                               .where("(responses.content IS NOT NULL AND responses.content != '') OR responses.score IS NOT NULL")
                               .count

    submitted_required >= total_required
  end
end
