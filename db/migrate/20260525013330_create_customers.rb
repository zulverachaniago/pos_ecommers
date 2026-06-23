class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone
      t.text :address
      t.string :type
      t.string :customer_type
      t.decimal :balance

      t.timestamps
    end
  end
end
