# frozen_string_literal: true

class Store::OrdersController < Store::BaseController
  before_action :authenticate_store_customer!
  before_action :set_order, only: [:show, :track]

  def index
    @orders = current_store_customer.orders
                                    .includes(order_items: { product_variant: :product })
                                    .order(created_at: :desc)
  end

  def show
  end

  def track
    render :show
  end

  def create
    cart_items = current_store_cart.cart_items.includes(product_variant: :product)

    if cart_items.empty?
      redirect_to store_cart_path, alert: "Keranjang kosong. Tambahkan produk terlebih dahulu."
      return
    end

    unless store_customer_address_ready?
      redirect_to store_cart_path, alert: "Alamat pengiriman belum diisi. Lengkapi alamat terlebih dahulu sebelum memesan."
      return
    end

    stock_totals = StockInventory.totals_hash(cart_items.map(&:product_variant_id))
    cart_items.each do |item|
      available = StockInventory.on_hand(item.product_variant, totals: stock_totals)
      next if item.quantity <= available

      redirect_to store_cart_path,
                  alert: "Stok #{item.product_variant.display_name} tidak mencukupi (tersedia: #{available})."
      return
    end

    order = nil

    ActiveRecord::Base.transaction do
      order = current_store_customer.orders.create!(
        total_amount: cart_items.sum(&:subtotal),
        order_status: :order,
        status: :pending,
        payment_method: order_payment_method
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

    redirect_to store_order_path(order), notice: "Pesanan #{order.order_number} berhasil dibuat."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to store_cart_path, alert: "Gagal membuat pesanan: #{e.record.errors.full_messages.to_sentence}"
  end

  private

  def order_payment_method
    method = params[:payment_method].to_s
    return :transfer if method == "transfer"

    :cod
  end

  def set_order
    @order = current_store_customer.orders
                                   .includes(
                                     order_items: { product_variant: :product },
                                     order_status_records: :user
                                   )
                                   .find(params[:id])
    @status_records = @order.order_status_records.chronological
  end
end
