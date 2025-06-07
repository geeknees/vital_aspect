class QuestionTemplate < ApplicationRecord
  belongs_to :organization

  serialize :options, type: Array, coder: JSON

  enum :question_type, {
    text: 0,
    rating: 1,
    multiple_choice: 2,
    yes_no: 3
  }

  validates :content, presence: true, length: { maximum: 500 }
  validates :question_type, presence: true

  scope :required, -> { where(is_required: true) }

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
