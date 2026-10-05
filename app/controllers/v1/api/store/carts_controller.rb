# frozen_string_literal: true

module V1
  module Api
    module Store
      class CartsController < BaseController
        before_action :require_customer!

        def show
          items = current_cart.cart_items.includes(product_variant: :product).order(created_at: :desc)
          totals = StockInventory.totals_hash(items.map(&:product_variant_id))
          render_success(cart_payload(items, totals))
        end

        def add_item
          variant = ProductVariant.includes(:product).find(params[:product_variant_id])
          requested = [params.fetch(:quantity, 1).to_i, 1].max
          available = StockInventory.on_hand(variant)
          item = current_cart.cart_items.find_or_initialize_by(product_variant: variant)
          new_quantity = (item.quantity || 0) + requested

          if available < new_quantity
            render_error("Stok #{variant.display_name} tidak mencukupi (tersedia: #{available}).")
            return
          end

          item.quantity = new_quantity
          item.save!
          render_success(message: "#{variant.product.name} ditambahkan ke keranjang.")
        end

        def update_item
          item = current_cart.cart_items.includes(product_variant: :product).find(params[:id])
          quantity = params[:quantity].to_i
          available = StockInventory.on_hand(item.product_variant)

          if quantity <= 0
            item.destroy!
            render_success(message: "Item dihapus dari keranjang.")
          elsif quantity > available
            render_error("Stok #{item.product_variant.display_name} tidak mencukupi (tersedia: #{available}).")
          else
            item.update!(quantity: quantity)
            render_success(message: "Jumlah item diperbarui.")
          end
        end

        def remove_item
          current_cart.cart_items.find(params[:id]).destroy!
          render_success(message: "Item dihapus dari keranjang.")
        end

        private

        def cart_payload(items, totals)
          {
            items: items.map { |item| json.cart_item(item, stock_totals: totals) },
            total_amount: items.sum(&:subtotal).to_f,
            items_count: items.sum(&:quantity)
          }
        end
      end
    end
  end
end
