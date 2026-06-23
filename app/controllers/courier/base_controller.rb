# frozen_string_literal: true

class Courier::BaseController < ApplicationController
  layout "courier"

  before_action :ensure_courier!

  private

  def ensure_courier!
    return if current_user&.has_role?(:courier)

    raise Pundit::NotAuthorizedError
  end
end
