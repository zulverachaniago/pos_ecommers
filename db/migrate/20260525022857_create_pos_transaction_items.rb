class CreatePosTransactionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :pos_transaction_items do |t|
      t.references :pos_transaction, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price_at_sale
      t.decimal :subtotal

      t.timestamps
    end
  end
end
