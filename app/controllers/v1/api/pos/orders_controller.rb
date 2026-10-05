# frozen_string_literal: true

module V1
  module Api
    module Pos
      class OrdersController < BaseController
        before_action :set_order, only: [:show, :update, :shipping_slip]

        def index
          authorize Order
          scope = Order.includes(order_includes).order(created_at: :desc)
          scope = scope.where.not(order_status: :done) if params[:filter].blank? || params[:filter] == "pending"
          orders = paginate_scope(scope)
          render_collection(orders, orders.map { |order| json.order(order) })
        end

        def show
          authorize @order
          render_success(json.order(@order))
        end

        def shipping_slip
          authorize @order, :shipping_slip?
          unless @order.order_status_process? || @order.order_status_ship? || @order.order_status_done?
            render_error("Label pengiriman tersedia setelah pesanan diproses.")
            return
          end

          render_success(json.order(@order))
        end

        def update
          authorize @order
          new_status = params.dig(:order, :order_status)
          notes = params.dig(:order, :notes)
          payment_method = params.dig(:order, :payment_method)

          @order.update!(payment_method: payment_method) if payment_method.present?

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
