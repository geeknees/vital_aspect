class CreateOkrs < ActiveRecord::Migration[8.0]
  def change
    create_table :okrs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_index :okrs, :status
    add_index :okrs, [ :organization_id, :user_id ]
    add_index :okrs, [ :start_date, :end_date ]
  end
end
