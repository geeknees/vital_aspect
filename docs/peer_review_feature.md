# Mutual Peer Reviews

This update introduces a new `PeerReview` model enabling evaluation participants to review one another.
Each peer review links a reviewer and a reviewee within the same evaluation.

```
PeerReview belongs_to :evaluation
PeerReview belongs_to :reviewer_participant (EvaluationParticipant)
PeerReview belongs_to :reviewee_participant (EvaluationParticipant)
```

Use the associations `given_peer_reviews` and `received_peer_reviews` on `EvaluationParticipant` to access these records.
