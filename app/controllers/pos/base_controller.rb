class Pos::BaseController < ApplicationController
  layout :resolve_pos_layout

  private

  def resolve_pos_layout
    current_user&.has_role?(:admin) ? "admin" : "cashier"
  end
end
