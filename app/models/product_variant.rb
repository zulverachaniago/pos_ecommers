# frozen_string_literal: true

class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :stock_movements, dependent: :restrict_with_error

  def current_stock
    stock_movements.sum(:quantity)
  end

  def display_name
    [product.name, variant_name].compact.join(" — ")
  end
end
