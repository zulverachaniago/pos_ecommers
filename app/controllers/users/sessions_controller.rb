# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout "application"

  def create
    self.resource = warden.authenticate!(auth_options)

    unless staff_user?(resource)
      sign_out(resource)
      flash[:alert] = "Akun pelanggan tidak dapat login di sini. Silakan gunakan login toko."
      redirect_to new_user_session_path and return
    end

    set_flash_message!(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.has_role?(:admin)
      admin_root_path
    elsif resource.has_role?(:owner)
      owner_root_path
    elsif resource.has_role?(:cashier)
      pos_root_path
    elsif resource.has_role?(:courier)
      courier_root_path
    else
      staff_login_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    staff_login_path
  end

  private

  def staff_user?(user)
    user.has_role?(:admin) || user.has_role?(:cashier) || user.has_role?(:owner) || user.has_role?(:courier)
  end
end
