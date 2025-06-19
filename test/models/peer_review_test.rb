require "test_helper"

class PeerReviewTest < ActiveSupport::TestCase
  setup do
    @evaluation = evaluations(:one)
    @participant1 = evaluation_participants(:one)
    @participant2 = evaluation_participants(:eval_one_peer2)
  end

  test "valid with participants from same evaluation" do
    review = PeerReview.new(
      evaluation: @evaluation,
      reviewer_participant: @participant1,
      reviewee_participant: @participant2
    )
    assert review.valid?
  end

  test "invalid when participants belong to different evaluations" do
    other = evaluation_participants(:two)
    review = PeerReview.new(
      evaluation: @evaluation,
      reviewer_participant: @participant1,
      reviewee_participant: other
    )
    assert_not review.valid?
  end

  test "duplicate reviewer and reviewee per evaluation is invalid" do
    PeerReview.create!(
      evaluation: @evaluation,
      reviewer_participant: @participant1,
      reviewee_participant: @participant2
    )

    dup = PeerReview.new(
      evaluation: @evaluation,
      reviewer_participant: @participant1,
      reviewee_participant: @participant2
    )
    assert_not dup.valid?
  end
end
