class AddOptionsToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :options, :text
  end
end
