class CreateKeyResults < ActiveRecord::Migration[8.0]
  def change
    create_table :key_results do |t|
      t.references :okr, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :target_value, precision: 10, scale: 2, null: false
      t.decimal :current_value, precision: 10, scale: 2, default: 0.0
      t.string :unit, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :key_results, :status
  end
end
