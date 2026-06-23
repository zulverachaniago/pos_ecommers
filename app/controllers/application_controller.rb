class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  include Pundit::Authorization
  include Paginatable
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def user_not_authorized
    flash[:alert] = "Anda tidak memiliki akses untuk melakukan tindakan ini."
    redirect_to(root_path)
  end

  # Helper method untuk cek role (optional tapi sangat membantu)
  def current_user_admin?
    current_user&.has_role?(:admin)
  end

  helper_method :current_user_admin?

end
