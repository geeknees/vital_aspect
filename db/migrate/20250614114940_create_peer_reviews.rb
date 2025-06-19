class CreatePeerReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :peer_reviews do |t|
      t.references :evaluation, null: false, foreign_key: true
      t.references :reviewer_participant,
                   null: false,
                   foreign_key: { to_table: :evaluation_participants }
      t.references :reviewee_participant,
                   null: false,
                   foreign_key: { to_table: :evaluation_participants }

      t.timestamps
    end

    add_index :peer_reviews,
              [ :evaluation_id, :reviewer_participant_id, :reviewee_participant_id ],
              unique: true,
              name: "index_peer_reviews_on_participants_and_evaluation"
  end
end
