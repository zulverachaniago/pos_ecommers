class NormalizePosTransactionPaymentMethods < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE pos_transactions SET payment_method = 'cash' WHERE payment_method IN ('0', 'cash');
      UPDATE pos_transactions SET payment_method = 'transfer' WHERE payment_method IN ('1', 'transfer');
    SQL
  end

  def down
  end
end
