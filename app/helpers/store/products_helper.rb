# frozen_string_literal: true

module Store::ProductsHelper
  def product_stock_summary(product, totals)
    StockInventory.product_summary(product.product_variants.to_a, totals: totals)
  end

  def variant_stock_snapshot(variant, totals)
    StockInventory.variant_snapshot(variant, totals: totals)
  end
end
