# frozen_string_literal: true

module V1
  module Api
    module Admin
      class CategoriesController < BaseController
        before_action :set_category, only: [:show, :update, :destroy]

        def index
          authorize Category
          categories = paginate_scope(Category.order(:name))
          render_collection(categories, categories.map { |category| json.category(category) })
        end

        def show
          authorize @category
          render_success(json.category(@category))
        end

        def create
          authorize Category
          category = Category.new(category_params)
          if category.save
            render_success(json.category(category), message: "Kategori berhasil ditambahkan.", status: :created)
          else
            render_invalid(category)
          end
        end

        def update
          authorize @category
          if @category.update(category_params)
            render_success(json.category(@category), message: "Kategori berhasil diupdate.")
          else
            render_invalid(@category)
          end
        end

        def destroy
          authorize @category
          @category.destroy!
          render_success(message: "Kategori berhasil dihapus.")
        rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey
          render_error("Kategori masih digunakan dan tidak dapat dihapus.")
        end

        private

        def set_category
          @category = Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :description)
        end
      end
    end
  end
end
