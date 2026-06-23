# frozen_string_literal: true

class Store::CartsController < Store::BaseController
  before_action :authenticate_store_customer!

  def show
    @cart_items = current_store_cart.cart_items.includes(product_variant: :product).order(created_at: :desc)
    @stock_totals = StockInventory.totals_hash(@cart_items.map(&:product_variant_id))
  end

  def add_item
    variant = ProductVariant.includes(:product).find(params[:product_variant_id])
    requested = quantity_param
    available = StockInventory.on_hand(variant)

    if available < requested
      redirect_back fallback_location: store_product_path(variant.product),
                    alert: "Stok #{variant.display_name} tidak mencukupi (tersedia: #{available})."
      return
    end

    item = current_store_cart.cart_items.find_or_initialize_by(product_variant: variant)
    new_quantity = (item.quantity || 0) + requested

    if available < new_quantity
      redirect_back fallback_location: store_product_path(variant.product),
                    alert: "Stok #{variant.display_name} tidak mencukupi (tersedia: #{available})."
      return
    end

    item.quantity = new_quantity
    item.save!

    redirect_back fallback_location: store_product_path(variant.product),
                  notice: "#{variant.product.name} ditambahkan ke keranjang."
  end

  def update_item
    item = current_store_cart.cart_items.includes(:product_variant).find(params[:id])
    quantity = params[:quantity].to_i
    available = StockInventory.on_hand(item.product_variant)

    if quantity <= 0
      item.destroy!
      notice = "Item dihapus dari keranjang."
    elsif quantity > available
      redirect_to store_cart_path,
                  alert: "Stok #{item.product_variant.display_name} tidak mencukupi (tersedia: #{available})."
      return
    else
      item.update!(quantity: quantity)
      notice = "Jumlah item diperbarui."
    end

    redirect_to store_cart_path, notice: notice
  end

  def remove_item
    item = current_store_cart.cart_items.find(params[:id])
    item.destroy!

    redirect_to store_cart_path, notice: "Item dihapus dari keranjang."
  end

  private

  def quantity_param
    [params.fetch(:quantity, 1).to_i, 1].max
  end
end
