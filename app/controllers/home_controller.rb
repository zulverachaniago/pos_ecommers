class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      if current_user.has_role?(:admin)
        redirect_to admin_root_path, notice: "Selamat datang di halaman admin"
      elsif current_user.has_role?(:owner)
        redirect_to owner_root_path, notice: "Selamat datang di halaman owner"
      elsif current_user.has_role?(:cashier)
        redirect_to pos_root_path, notice: "Selamat datang, siap melayani di kasir"
      elsif current_user.has_role?(:courier)
        redirect_to courier_root_path, notice: "Selamat datang, siap mengirim pesanan"
      elsif current_user.has_role?(:customer)
        redirect_to store_products_path, notice: "Selamat datang di toko online"
      else
        redirect_to store_products_path
      end
    end
  end
end
