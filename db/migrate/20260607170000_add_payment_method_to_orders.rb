# frozen_string_literal: true

class AddPaymentMethodToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_method, :integer, default: 1, null: false
    add_index :orders, :payment_method
  end
end
