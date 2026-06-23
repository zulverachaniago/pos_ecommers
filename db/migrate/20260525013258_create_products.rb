class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.string :sku
      t.string :barcode
      t.boolean :is_active

      t.timestamps
    end
  end
end
