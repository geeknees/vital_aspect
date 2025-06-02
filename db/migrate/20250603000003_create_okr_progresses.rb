class CreateOkrProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :okr_progresses do |t|
      t.references :okr, null: false, foreign_key: true
      t.text :progress_note, null: false
      t.decimal :completion_percentage, precision: 5, scale: 2, default: 0.0
      t.date :reported_at, null: false

      t.timestamps
    end

    add_index :okr_progresses, :reported_at
  end
end
