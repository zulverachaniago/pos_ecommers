# frozen_string_literal: true

class CreateOrderStatusRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_records do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.integer :order_status, null: false
      t.text :notes

      t.timestamps
    end

    add_index :order_status_records, [:order_id, :created_at]

    reversible do |dir|
      dir.up do
        order_model = Class.new(ActiveRecord::Base) { self.table_name = "orders" }
        record_model = Class.new(ActiveRecord::Base) { self.table_name = "order_status_records" }

        customer_model = Class.new(ActiveRecord::Base) { self.table_name = "customers" }
        user_by_customer = customer_model.pluck(:id, :user_id).to_h

        say_with_time "Backfill order status records for existing orders" do
          order_model.find_each do |order|
            record_model.create!(
              order_id: order.id,
              order_status: order.order_status,
              user_id: user_by_customer[order.customer_id],
              notes: "Pesanan dibuat",
              created_at: order.created_at,
              updated_at: order.created_at
            )
          end
        end
      end
    end
  end
end
