class Response < ApplicationRecord
  belongs_to :question
  belongs_to :evaluation_participant, foreign_key: :participant_id

  validates :participant_id, uniqueness: { scope: :question_id }
  validate :content_or_score_present
  validate :score_within_range, if: :score?

  scope :with_content, -> { where.not(content: [ nil, "" ]) }
  scope :with_score, -> { where.not(score: nil) }

  def answered?
    content.present? || score.present?
  end

  def display_value
    if question.rating? || question.yes_no?
      score_label
    else
      content
    end
  end

  private

  def content_or_score_present
    if question.text? || question.multiple_choice?
      errors.add(:content, "回答を入力してください") if content.blank?
    elsif question.rating? || question.yes_no?
      errors.add(:score, "評点を選択してください") if score.blank?
    end
  end

  def score_within_range
    case question.question_type
    when "rating"
      errors.add(:score, "1から5の間で選択してください") unless score.between?(1, 5)
    when "yes_no"
      errors.add(:score, "0または1を選択してください") unless [ 0, 1 ].include?(score)
    end
  end

  def score_label
    case question.question_type
    when "rating"
      "#{score} - #{rating_label}"
    when "yes_no"
      score == 1 ? "はい" : "いいえ"
    else
      score.to_s
    end
  end

  def rating_label
    labels = [ "", "全く当てはまらない", "あまり当てはまらない", "どちらとも言えない", "やや当てはまる", "非常に当てはまる" ]
    labels[score] || ""
  end
end
