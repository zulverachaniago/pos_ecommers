# frozen_string_literal: true

module V1
  module Api
    module Admin
      class SuppliersController < BaseController
        before_action :set_supplier, only: [:show, :update, :destroy]

        def index
          authorize Supplier
          suppliers = paginate_scope(Supplier.order(:name))
          render_collection(suppliers, suppliers.map { |supplier| json.supplier(supplier) })
        end

        def show
          authorize @supplier
          render_success(json.supplier(@supplier))
        end

        def create
          authorize Supplier
          supplier = Supplier.new(supplier_params)
          if supplier.save
            render_success(json.supplier(supplier), message: "Supplier berhasil ditambahkan.", status: :created)
          else
            render_invalid(supplier)
          end
        end

        def update
          authorize @supplier
          if @supplier.update(supplier_params)
            render_success(json.supplier(@supplier), message: "Supplier berhasil diupdate.")
          else
            render_invalid(@supplier)
          end
        end

        def destroy
          authorize @supplier
          @supplier.destroy!
          render_success(message: "Supplier berhasil dihapus.")
        rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey
          render_error("Supplier masih digunakan dan tidak dapat dihapus.")
        end

        private

        def set_supplier
          @supplier = Supplier.find(params[:id])
        end

        def supplier_params
          params.require(:supplier).permit(:name, :contact_person, :phone, :address)
        end
      end
    end
  end
end
