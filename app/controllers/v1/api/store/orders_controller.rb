# frozen_string_literal: true

module V1
  module Api
    module Store
      class OrdersController < BaseController
        before_action :require_customer!
        before_action :set_order, only: [:show, :track]

        def index
          orders = paginate_scope(
            current_customer.orders.includes(order_includes).order(created_at: :desc)
          )
          render_collection(orders, orders.map { |order| json.order(order) })
        end

        def show
          render_success(json.order(@order))
        end

        def track
          render_success(json.order(@order))
        end

        def create
          cart_items = current_cart.cart_items.includes(product_variant: :product)
          if cart_items.empty?
            render_error("Keranjang kosong. Tambahkan produk terlebih dahulu.")
            return
          end

          if current_customer.address.blank?
            render_error("Alamat pengiriman belum diisi.")
            return
          end

          totals = StockInventory.totals_hash(cart_items.map(&:product_variant_id))
          cart_items.each do |item|
            available = StockInventory.on_hand(item.product_variant, totals: totals)
            next if item.quantity <= available

            render_error("Stok #{item.product_variant.display_name} tidak mencukupi (tersedia: #{available}).")
            return
          end

          order = nil
          ActiveRecord::Base.transaction do
            order = current_customer.orders.create!(
              total_amount: cart_items.sum(&:subtotal),
              order_status: :order,
              status: :pending,
              payment_method: payment_method_param,
              notes: params[:notes]
            )

            cart_items.each do |item|
              variant = item.product_variant
              order.order_items.create!(
                product_variant: variant,
                quantity: item.quantity,
                price_at_sale: variant.price_grosir,
                subtotal: item.subtotal
              )
            end

            order.record_order_status!(user: current_user, notes: "Pesanan dibuat")
            cart_items.destroy_all
          end

          order = current_customer.orders.includes(order_includes).find(order.id)
          render_success(json.order(order), message: "Pesanan #{order.order_number} berhasil dibuat.", status: :created)
        rescue ActiveRecord::RecordInvalid => e
          render_error("Gagal membuat pesanan: #{e.record.errors.full_messages.to_sentence}")
        end

        private

        def set_order
          @order = current_customer.orders.includes(order_includes).find(params[:id])
        end

        def payment_method_param
          params[:payment_method].to_s == "transfer" ? :transfer : :cod
        end
      end
    end
  end
end
