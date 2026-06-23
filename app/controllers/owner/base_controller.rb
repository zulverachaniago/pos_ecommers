# frozen_string_literal: true

class Owner::BaseController < ApplicationController
  include ExportRespondable

  layout "owner"

  before_action :ensure_owner!

  private

  def ensure_owner!
    return if current_user&.has_role?(:owner)

    raise Pundit::NotAuthorizedError
  end

  def pundit_user
    current_user
  end
end
