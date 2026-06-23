class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  delegate :product, to: :product_variant

  def subtotal
    (product_variant.price_grosir || 0) * quantity
  end
end
