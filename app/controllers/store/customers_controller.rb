# frozen_string_literal: true

class Store::CustomersController < Store::BaseController
  before_action :ensure_customer!
  before_action :set_customer

  def edit
    @return_to_cart = params[:return_to] == "cart"
  end

  def update
    if @customer.update(customer_params)
      redirect_to after_profile_update_path, notice: profile_update_notice
    else
      @return_to_cart = params[:return_to] == "cart"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def after_profile_update_path
    params[:return_to] == "cart" ? store_cart_path : store_products_path
  end

  def profile_update_notice
    if params[:return_to] == "cart" && @customer.address.present?
      "Alamat berhasil disimpan. Silakan lanjutkan pesanan Anda."
    else
      "Profil warung berhasil diperbarui."
    end
  end

  def ensure_customer!
    return if current_user.has_role?(:customer)

    redirect_to store_products_path, alert: "Halaman ini hanya untuk pelanggan."
  end

  def set_customer
    @customer = current_user.customer || current_user.create_customer_profile
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :address, :customer_type)
  end
end
