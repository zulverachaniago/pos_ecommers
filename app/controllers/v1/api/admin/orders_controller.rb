# frozen_string_literal: true

module V1
  module Api
    module Admin
      class OrdersController < BaseController
        before_action :set_order, only: [:show, :update]

        def index
          authorize Order
          orders = paginate_scope(Order.includes(order_includes).order(created_at: :desc))
          render_collection(orders, orders.map { |order| json.order(order) })
        end

        def show
          authorize @order
          render_success(json.order(@order))
        end

        def update
          authorize @order
          new_status = params.dig(:order, :order_status)
          notes = params.dig(:order, :notes)

          if @order.update_order_status!(new_status, user: current_user, notes: notes.presence)
            @order = Order.includes(order_includes).find(@order.id)
            render_success(json.order(@order), message: "Status pesanan diperbarui.")
          elsif @order.errors[:base].any?
            render_error(@order.errors[:base].to_sentence)
          else
            render_error("Status tidak berubah atau tidak valid.")
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
