# frozen_string_literal: true

module V1
  module Api
    module Catalog
      class ProductsController < BaseController
        skip_before_action :authenticate_api_user!, only: [:index, :show]

        def index
          scope = Product.includes(:category, :supplier, :product_variants).with_attached_image.where(is_active: true)
          scope = apply_catalog_filters(scope)
          products = paginate_scope(scope.order(name: :asc))
          totals = stock_totals_for(products)

          render_collection(products, products.map { |product| json.product(product, stock_totals: totals) })
        end

        def show
          product = Product.includes(:category, :supplier, :product_variants).with_attached_image.find(params[:id])
          totals = StockInventory.totals_hash(product.product_variant_ids)
          render_success(json.product(product, stock_totals: totals))
        end

        private

        def apply_catalog_filters(scope)
          if params[:search].present?
            term = "%#{params[:search].to_s.strip}%"
            scope = scope.where("products.name ILIKE :term OR products.sku ILIKE :term OR products.barcode ILIKE :term", term: term)
          end
          scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
          scope
        end

        def stock_totals_for(products)
          StockInventory.totals_hash(products.flat_map { |product| product.product_variants.map(&:id) })
        end
      end
    end
  end
end
