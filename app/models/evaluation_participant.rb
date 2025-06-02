class EvaluationParticipant < ApplicationRecord
  belongs_to :evaluation
  belongs_to :user
  has_many :responses, dependent: :destroy

  enum :role, {
    self_evaluator: 0,    # 自己評価者
    peer: 1,              # 同僚
    supervisor: 2,        # 上司
    subordinate: 3        # 部下
  }

  enum :status, {
    invited: 0,           # 招待済み
    in_progress: 1,       # 回答中
    completed: 2,         # 回答完了
    declined: 3           # 辞退
  }

  validates :user_id, uniqueness: { scope: :evaluation_id }
  validates :role, presence: true
  validates :status, presence: true

  scope :by_role, ->(role) { where(role: role) }
  scope :completed_participants, -> { where(status: :completed) }
  scope :pending_participants, -> { where(status: [ :invited, :in_progress ]) }

  def can_respond?
    evaluation.active? && !completed? && !declined?
  end

  def response_progress
    total_questions = evaluation.questions.count
    return 0 if total_questions.zero?

    answered_questions = responses.where.not(content: [ nil, "" ]).count
    (answered_questions.to_f / total_questions * 100).round
  end

  def all_required_responses_completed?
    required_questions = evaluation.questions.where(is_required: true)
    answered_required = responses.joins(:question)
                               .where(questions: { is_required: true })
                               .where.not(content: [ nil, "" ])
                               .count

    answered_required >= required_questions.count
  end

  def needs_reminder?
    # Send reminder if evaluation is active, participant hasn't completed,
    # and the due date is within 3 days
    evaluation.active? &&
    (invited? || in_progress?) &&
    evaluation.due_date.present? &&
    evaluation.due_date >= Date.current &&
    evaluation.due_date <= 3.days.from_now
  end
end
