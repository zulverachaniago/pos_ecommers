class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price_at_sale
      t.decimal :subtotal

      t.timestamps
    end
  end
end
