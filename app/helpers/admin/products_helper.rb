# frozen_string_literal: true

module Admin::ProductsHelper
  def product_total_stock(product, totals)
    product.product_variants.sum { |variant| StockInventory.on_hand(variant, totals: totals) }
  end

  def product_stock_status(product, totals)
    snapshots = product.product_variants.map do |variant|
      StockInventory.variant_snapshot(variant, totals: totals)
    end
    return :out if snapshots.empty?

    snapshots.map { |snapshot| snapshot[:status] }.max_by { |status| %i[out low available].index(status) }
  end
end
