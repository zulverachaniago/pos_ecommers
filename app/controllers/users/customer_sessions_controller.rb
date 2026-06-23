# frozen_string_literal: true

class Users::CustomerSessionsController < Devise::SessionsController
  layout "application"

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    render "devise/sessions/new"
  end

  def create
    self.resource = warden.authenticate!(auth_options)

    unless resource.has_role?(:customer)
      sign_out(resource)
      flash[:alert] = "Akun staff tidak dapat login di sini. Gunakan halaman login staff."
      redirect_to staff_login_path and return
    end

    set_flash_message!(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || store_products_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
