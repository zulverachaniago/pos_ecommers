# frozen_string_literal: true

module V1
  module Api
    module Store
      class WishlistsController < BaseController
        before_action :require_customer!

        def index
          items = paginate_scope(
            current_customer.wishlist_items
                            .includes(product: [:category, :supplier, :product_variants])
                            .order(created_at: :desc)
          )
          products = items.map(&:product)
          totals = StockInventory.totals_hash(products.flat_map { |product| product.product_variants.map(&:id) })
          render_collection(items, items.map { |item| json.wishlist_item(item, stock_totals: totals) })
        end

        def toggle
          product = Product.find(params[:product_id])
          item = current_customer.wishlist_items.find_by(product: product)

          if item
            item.destroy!
            render_success({ wishlisted: false, product_id: product.id }, message: "#{product.name} dihapus dari wishlist.")
          else
            current_customer.wishlist_items.create!(product: product)
            render_success({ wishlisted: true, product_id: product.id }, message: "#{product.name} ditambahkan ke wishlist.")
          end
        end

        def destroy
          item = current_customer.wishlist_items.includes(:product).find(params[:id])
          name = item.product.name
          item.destroy!
          render_success(message: "#{name} dihapus dari wishlist.")
        end
      end
    end
  end
end
