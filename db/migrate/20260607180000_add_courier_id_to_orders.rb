# frozen_string_literal: true

class AddCourierIdToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :courier, foreign_key: { to_table: :users }, null: true
  end
end
