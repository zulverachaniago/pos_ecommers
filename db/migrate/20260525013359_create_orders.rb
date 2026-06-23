class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.integer :status
      t.decimal :total_amount
      t.text :notes
      t.datetime :order_date

      t.timestamps
    end
  end
end
