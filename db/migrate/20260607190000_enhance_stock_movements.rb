# frozen_string_literal: true

class EnhanceStockMovements < ActiveRecord::Migration[8.1]
  def change
    change_column_null :stock_movements, :referenceable_id, true
    change_column_null :stock_movements, :referenceable_type, true

    add_column :stock_movements, :stock_before, :integer
    add_column :stock_movements, :stock_after, :integer

    add_index :stock_movements, :movement_type
    add_index :stock_movements, :created_at
  end
end
