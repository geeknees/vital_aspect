class CreateQuestionTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :question_templates do |t|
      t.references :organization, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :question_type, null: false, default: 0
      t.boolean :is_required, default: true
      t.text :options

      t.timestamps
    end
  end
end
