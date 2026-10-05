# frozen_string_literal: true

module V1
  module Api
    module Pos
      class ProductsController < BaseController
        def index
          authorize PosTransaction, :index?
          scope = ProductVariant.joins(:product)
                                .where(products: { is_active: true })
                                .includes(product: { image_attachment: :blob })
                                .order("products.name")

          if params[:search].present?
            term = "%#{params[:search].to_s.strip}%"
            scope = scope.where(
              "products.name ILIKE :term OR products.sku ILIKE :term OR products.barcode ILIKE :term OR product_variants.variant_name ILIKE :term",
              term: term
            )
          end

          variants = paginate_scope(scope)
          totals = StockInventory.totals_hash(variants.map(&:id))
          render_collection(variants, variants.map { |variant| json.pos_catalog_variant(variant, stock_totals: totals) })
        end
      end
    end
  end
end
