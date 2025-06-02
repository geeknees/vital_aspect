class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :question, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: { to_table: :evaluation_participants }
      t.text :content
      t.integer :score

      t.timestamps
    end

    add_index :responses, [ :question_id, :participant_id ], unique: true
  end
end
