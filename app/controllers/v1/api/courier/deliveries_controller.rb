# frozen_string_literal: true

module V1
  module Api
    module Courier
      class DeliveriesController < BaseController
        before_action :require_courier!
        before_action :set_order, only: [:show, :pickup]

        def index
          authorize Order, policy_class: ::Courier::DeliveryPolicy
          scope = Order.ready_for_courier.includes(order_includes).order(created_at: :asc)
          scope = scope.search_by_number(params[:q]) if params[:q].present?
          orders = paginate_scope(scope)
          render_collection(orders, orders.map { |order| json.order(order) })
        end

        def show
          authorize @order, policy_class: ::Courier::DeliveryPolicy
          render_success(json.order(@order))
        end

        def pickup
          authorize @order, :pickup?, policy_class: ::Courier::DeliveryPolicy
          notes = params.dig(:order, :notes)
          if @order.pickup_by_courier!(current_user, notes: notes)
            @order = Order.includes(order_includes).find(@order.id)
            render_success(json.order(@order), message: "Pesanan #{@order.order_number} siap dikirim.")
          else
            render_error("Pesanan tidak dapat diambil.")
          end
        end

        private

        def set_order
          @order = Order.includes(order_includes).find(params[:id])
        end
      end
    end
  end
end
