# frozen_string_literal: true

class Store::BaseController < ApplicationController
  layout "store"

  helper_method :current_store_customer,
                :current_store_cart,
                :store_cart_items_count,
                :store_wishlist_product_ids,
                :product_wishlisted?,
                :store_wishlist_count,
                :store_customer_signed_in?,
                :store_customer_address_ready?

  private

  def store_customer_signed_in?
    user_signed_in? && current_user.has_role?(:customer)
  end

  def current_store_customer
    return unless store_customer_signed_in?

    current_user.customer || current_user.create_customer_profile
  end

  def current_store_cart
    customer = current_store_customer
    return unless customer

    customer.cart || customer.create_cart!
  end

  def store_cart_items_count
    cart = current_store_cart
    return 0 unless cart

    cart.cart_items.sum(:quantity)
  end

  def store_wishlist_product_ids
    return @store_wishlist_product_ids if defined?(@store_wishlist_product_ids)

    @store_wishlist_product_ids =
      if current_store_customer
        current_store_customer.wishlist_items.pluck(:product_id)
      else
        []
      end
  end

  def product_wishlisted?(product)
    store_wishlist_product_ids.include?(product.id)
  end

  def store_wishlist_count
    store_wishlist_product_ids.size
  end

  def store_customer_address_ready?
    current_store_customer&.address.present?
  end

  def authenticate_store_customer!
    return if current_store_customer

    if user_signed_in?
      redirect_to store_products_path, alert: "Fitur ini hanya untuk akun pelanggan."
    else
      redirect_to new_user_session_path, alert: "Silakan login sebagai pelanggan untuk melanjutkan."
    end
  end
end
