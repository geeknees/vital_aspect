class Question < ApplicationRecord
  belongs_to :evaluation
  has_many :responses, dependent: :destroy

  # Serialize options as JSON for multiple choice questions
  serialize :options, type: Array, coder: JSON

  enum :question_type, {
    text: 0,              # テキスト回答
    rating: 1,            # 評点（1-5など）
    multiple_choice: 2,   # 選択肢
    yes_no: 3            # はい/いいえ
  }

  validates :content, presence: true, length: { maximum: 500 }
  validates :order_index, presence: true, uniqueness: { scope: :evaluation_id }
  validates :question_type, presence: true

  scope :ordered, -> { order(:order_index) }
  scope :required, -> { where(is_required: true) }

  def self.reorder_questions!(evaluation, question_ids)
    transaction do
      question_ids.each_with_index do |id, index|
        evaluation.questions.find(id).update!(order_index: index + 1)
      end
    end
  end

  def rating_options
    case question_type
    when "rating"
      [
        [ "1 - 全く当てはまらない", 1 ],
        [ "2 - あまり当てはまらない", 2 ],
        [ "3 - どちらとも言えない", 3 ],
        [ "4 - やや当てはまる", 4 ],
        [ "5 - 非常に当てはまる", 5 ]
      ]
    when "yes_no"
      [
        [ "はい", 1 ],
        [ "いいえ", 0 ]
      ]
    else
      []
    end
  end
end
