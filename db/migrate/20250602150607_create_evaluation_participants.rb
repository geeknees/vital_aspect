class CreateEvaluationParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :evaluation_participants do |t|
      t.references :evaluation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :evaluation_participants, [ :evaluation_id, :user_id ], unique: true
  end
end
