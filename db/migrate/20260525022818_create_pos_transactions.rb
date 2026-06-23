class CreatePosTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :pos_transactions do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :transaction_number
      t.decimal :total_amount
      t.string :payment_method
      t.integer :payment_status

      t.timestamps
    end
  end
end
