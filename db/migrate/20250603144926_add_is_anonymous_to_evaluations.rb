class AddIsAnonymousToEvaluations < ActiveRecord::Migration[8.0]
  def change
    add_column :evaluations, :is_anonymous, :boolean, default: false, null: false
  end
end
