class DropPeerReviews < ActiveRecord::Migration[8.0]
  def change
    drop_table :peer_reviews do |t|
      t.integer :evaluation_id, null: false
      t.integer :reviewer_participant_id, null: false
      t.integer :reviewee_participant_id, null: false
      t.timestamps

      t.index [ :evaluation_id, :reviewer_participant_id, :reviewee_participant_id ],
              name: "index_peer_reviews_on_participants_and_evaluation",
              unique: true
      t.index [ :evaluation_id ], name: "index_peer_reviews_on_evaluation_id"
      t.index [ :reviewer_participant_id ], name: "index_peer_reviews_on_reviewer_participant_id"
      t.index [ :reviewee_participant_id ], name: "index_peer_reviews_on_reviewee_participant_id"
    end
  end
end
