class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :variant_name
      t.decimal :price_grosir
      t.decimal :price_ecer
      t.integer :stock_minimum
      t.string :unit

      t.timestamps
    end
  end
end
