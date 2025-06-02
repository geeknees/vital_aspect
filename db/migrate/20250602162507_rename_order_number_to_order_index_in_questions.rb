class RenameOrderNumberToOrderIndexInQuestions < ActiveRecord::Migration[8.0]
  def change
    rename_column :questions, :order_number, :order_index
  end
end
