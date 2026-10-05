# frozen_string_literal: true

module V1
  module Api
    module Admin
      class CustomersController < BaseController
        before_action :set_customer, only: [:show, :update, :destroy]

        def index
          authorize Customer
          customers = paginate_scope(Customer.order(name: :asc))
          render_collection(customers, customers.map { |customer| json.customer(customer) })
        end

        def show
          authorize @customer
          render_success(json.customer(@customer))
        end

        def create
          authorize Customer
          customer = Customer.new(customer_params)
          if customer.save
            render_success(json.customer(customer), message: "Pelanggan berhasil ditambahkan.", status: :created)
          else
            render_invalid(customer)
          end
        end

        def update
          authorize @customer
          if @customer.update(customer_params)
            render_success(json.customer(@customer), message: "Data pelanggan berhasil diupdate.")
          else
            render_invalid(@customer)
          end
        end

        def destroy
          authorize @customer
          @customer.destroy!
          render_success(message: "Pelanggan berhasil dihapus.")
        rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey
          render_error("Pelanggan masih memiliki data terkait dan tidak dapat dihapus.")
        end

        private

        def set_customer
          @customer = Customer.includes(:user).find(params[:id])
        end

        def customer_params
          params.require(:customer).permit(:name, :phone, :address, :customer_type, :balance)
        end
      end
    end
  end
end
