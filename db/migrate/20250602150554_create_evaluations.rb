class CreateEvaluations < ActiveRecord::Migration[8.0]
  def change
    create_table :evaluations do |t|
      t.string :title, null: false
      t.text :description
      t.references :organization, null: false, foreign_key: true
      t.references :evaluator, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.datetime :due_date
      t.datetime :start_date

      t.timestamps
    end
  end
end
