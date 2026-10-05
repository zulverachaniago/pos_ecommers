# frozen_string_literal: true

module V1
  module Api
    module Courier
      class CompletedController < BaseController
        before_action :require_courier!
        before_action :set_order, only: [:show, :finish]

        def index
          authorize Order, policy_class: ::Courier::DeliveryPolicy
          scope = Order.courier_active(current_user).includes(order_includes).order(updated_at: :desc)
          scope = scope.search_by_number(params[:q]) if params[:q].present?
          orders = paginate_scope(scope)
          render_collection(orders, orders.map { |order| json.order(order) })
        end

        def show
          authorize @order, policy_class: ::Courier::DeliveryPolicy
          render_success(json.order(@order))
        end

        def finish
          authorize @order, :finish?, policy_class: ::Courier::DeliveryPolicy
          notes = params.dig(:order, :notes)
          if @order.complete_by_courier!(current_user, notes: notes)
            @order = Order.includes(order_includes).find(@order.id)
            render_success(json.order(@order), message: "Pesanan #{@order.order_number} selesai dikirim.")
          else
            render_error(@order.errors[:base].to_sentence.presence || "Pesanan tidak dapat diselesaikan.")
          end
        end

        private

        def set_order
          @order = Order.includes(order_includes).where(courier_id: current_user.id).find(params[:id])
        end
      end
    end
  end
end
