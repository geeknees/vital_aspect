class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :evaluation, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :question_type, default: 0, null: false
      t.integer :order_number, null: false
      t.boolean :is_required, default: true

      t.timestamps
    end

    add_index :questions, [ :evaluation_id, :order_number ]
  end
end
