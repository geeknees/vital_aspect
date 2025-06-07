require "test_helper"

class QuestionTemplateTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:test_org)
  end

  test "valid template" do
    template = QuestionTemplate.new(
      organization: @organization,
      content: "How do you rate teamwork?",
      question_type: "rating",
      is_required: true,
      options: [ "1", "2", "3", "4", "5" ]
    )

    assert template.valid?
  end

  test "invalid without content" do
    template = QuestionTemplate.new(
      organization: @organization,
      question_type: "text"
    )
    assert_not template.valid?
  end
end
