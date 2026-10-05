# frozen_string_literal: true

module V1
  module Api
    module Catalog
      class CategoriesController < BaseController
        skip_before_action :authenticate_api_user!, only: [:index, :show]

        def index
          categories = paginate_scope(Category.order(:name))
          render_collection(categories, categories.map { |category| json.category(category) })
        end

        def show
          render_success(json.category(Category.find(params[:id])))
        end
      end
    end
  end
end
