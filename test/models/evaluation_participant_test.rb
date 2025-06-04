require "test_helper"

class EvaluationParticipantTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:test_org)
    @evaluator    = users(:owner)
    @user         = users(:member)
  end

  test "all_required_responses_completed? counts answered text questions" do
    evaluation = Evaluation.create!(
      title: "Quarterly Review",
      description: "",
      organization: @organization,
      evaluator: @evaluator,
      status: :active,
      start_date: Time.zone.today,
      due_date: 1.day.from_now
    )

    question = evaluation.questions.create!(
      content: "Describe your achievements",
      question_type: :text,
      order_index: 1,
      is_required: true
    )

    participant = EvaluationParticipant.create!(
      evaluation: evaluation,
      user: @user,
      role: :peer,
      status: :in_progress
    )

    assert_not participant.all_required_responses_completed?, "no responses yet"

    Response.create!(question: question, evaluation_participant: participant, content: "Great work")

    assert participant.all_required_responses_completed?, "text response should count"
  end

  test "all_required_responses_completed? counts rating questions answered by score" do
    evaluation = Evaluation.create!(
      title: "Quarterly Review",
      description: "",
      organization: @organization,
      evaluator: @evaluator,
      status: :active,
      start_date: Time.zone.today,
      due_date: 1.day.from_now
    )

    question = evaluation.questions.create!(
      content: "Rate overall performance",
      question_type: :rating,
      order_index: 1,
      is_required: true
    )

    participant = EvaluationParticipant.create!(
      evaluation: evaluation,
      user: @user,
      role: :peer,
      status: :in_progress
    )

    assert_not participant.all_required_responses_completed?, "no responses yet"

    Response.create!(question: question, evaluation_participant: participant, score: 4)

    assert participant.all_required_responses_completed?, "rating score should count"
  end
end
