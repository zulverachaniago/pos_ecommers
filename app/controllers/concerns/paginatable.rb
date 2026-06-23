# frozen_string_literal: true

module Paginatable
  extend ActiveSupport::Concern

  PER_PAGE = 20

  private

  def paginate_scope(scope)
    scope.page(params[:page]).per(PER_PAGE)
  end
end
