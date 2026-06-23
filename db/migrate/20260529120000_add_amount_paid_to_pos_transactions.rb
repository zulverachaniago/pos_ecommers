class AddAmountPaidToPosTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :pos_transactions, :amount_paid, :decimal, precision: 12, scale: 2
  end
end
