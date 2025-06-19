class PeerReview < ApplicationRecord
  belongs_to :evaluation
  belongs_to :reviewer_participant, class_name: "EvaluationParticipant"
  belongs_to :reviewee_participant, class_name: "EvaluationParticipant"

  validate :participants_belong_to_evaluation
  validates :reviewee_participant_id,
            uniqueness: { scope: [ :evaluation_id, :reviewer_participant_id ] }

  private

  def participants_belong_to_evaluation
    if reviewer_participant && reviewer_participant.evaluation_id != evaluation_id
      errors.add(:reviewer_participant, "must belong to the evaluation")
    end
    if reviewee_participant && reviewee_participant.evaluation_id != evaluation_id
      errors.add(:reviewee_participant, "must belong to the evaluation")
    end
  end
end
