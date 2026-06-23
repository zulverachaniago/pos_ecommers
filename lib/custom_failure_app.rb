# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def redirect_url
    if staff_area_request?
      staff_login_url
    else
      new_user_session_url
    end
  end

  private

  def staff_area_request?
    path = attempted_path.presence || request.original_fullpath.to_s
    path.match?(%r{\A/(admin|owner|pos)(/|$)})
  end
end
