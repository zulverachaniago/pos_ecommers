# frozen_string_literal: true

module V1
  module Api
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: [:show, :update, :destroy]

        def index
          authorize Product
          query = Product.ransack(params[:q])
          scope = query.result(distinct: true)
                       .includes(:category, :supplier, :product_variants)
                       .with_attached_image
                       .order(name: :asc)
          products = paginate_scope(scope)
          totals = StockInventory.totals_hash(products.flat_map { |product| product.product_variants.map(&:id) })
          render_collection(products, products.map { |product| json.product(product, stock_totals: totals) })
        end

        def show
          authorize @product
          totals = StockInventory.totals_hash(@product.product_variant_ids)
          render_success(json.product(@product, stock_totals: totals))
        end

        def create
          authorize Product
          product = Product.new(product_params)
          if product.save
            totals = StockInventory.totals_hash(product.product_variant_ids)
            render_success(json.product(product, stock_totals: totals), message: "Produk berhasil ditambahkan.", status: :created)
          else
            render_invalid(product)
          end
        end

        def update
          authorize @product
          if @product.update(product_params)
            totals = StockInventory.totals_hash(@product.product_variant_ids)
            render_success(json.product(@product, stock_totals: totals), message: "Produk berhasil diupdate.")
          else
            render_invalid(@product)
          end
        end

        def destroy
          authorize @product
          @product.destroy!
          render_success(message: "Produk berhasil dihapus.")
        rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey
          render_error("Produk masih digunakan dan tidak dapat dihapus.")
        end

        private

        def set_product
          @product = Product.includes(:category, :supplier, :product_variants).with_attached_image.find(params[:id])
        end

        def product_params
          params.require(:product).permit(
            :name, :description, :category_id, :supplier_id, :sku, :barcode, :is_active, :image,
            product_variants_attributes: [:id, :variant_name, :price_grosir, :price_ecer, :stock_minimum, :unit, :_destroy]
          )
        end
      end
    end
  end
end
