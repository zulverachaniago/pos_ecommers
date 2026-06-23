class PosTransactionItem < ApplicationRecord
  belongs_to :pos_transaction
  belongs_to :product_variant

  def subtotal
    quantity * price_at_sale
  end
end