class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :movement_type
      t.integer :quantity
      t.text :notes
      t.references :referenceable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
