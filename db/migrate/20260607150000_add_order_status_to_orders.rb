# frozen_string_literal: true

class AddOrderStatusToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_status, :integer, default: 1, null: false
    add_column :orders, :order_number, :string
    add_index :orders, :order_number, unique: true
    add_index :orders, :order_status
  end
end
