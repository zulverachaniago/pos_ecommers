# frozen_string_literal: true

class Store::WishlistsController < Store::BaseController
  before_action :authenticate_store_customer!

  def index
    @wishlist_items = current_store_customer.wishlist_items
                                            .includes(product: %i[category product_variants])
                                            .order(created_at: :desc)
  end

  def toggle
    product = Product.find(params[:product_id])
    item = current_store_customer.wishlist_items.find_by(product: product)

    if item
      item.destroy!
      notice = "#{product.name} dihapus dari wishlist."
    else
      current_store_customer.wishlist_items.create!(product: product)
      notice = "#{product.name} ditambahkan ke wishlist."
    end

    redirect_back fallback_location: store_products_path, notice: notice
  end

  def destroy
    item = current_store_customer.wishlist_items.find(params[:id])
    name = item.product.name
    item.destroy!

    redirect_to store_wishlists_path, notice: "#{name} dihapus dari wishlist."
  end
end
