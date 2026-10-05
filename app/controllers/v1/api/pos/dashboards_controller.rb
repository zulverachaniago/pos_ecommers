# frozen_string_literal: true

module V1
  module Api
    module Pos
      class DashboardsController < BaseController
        def show
          authorize :dashboard, :index?
          today = SalesMetrics.new(Time.zone.today.all_day)
          week = SalesMetrics.new(Time.zone.today.beginning_of_week..Time.zone.today.end_of_day)
          recent_transactions = PosTransaction.includes(:customer, :user, pos_transaction_items: { product_variant: :product })
                                              .order(created_at: :desc)
                                              .limit(5)
          recent_orders = Order.active_sales.includes(order_includes).order(created_at: :desc).limit(5)

          render_success({
            today: {
              total: today.combined_sales.to_f,
              pos: today.pos_sales.to_f,
              online: today.online_sales.to_f,
              count: today.combined_count
            },
            week: {
              total: week.combined_sales.to_f,
              count: week.combined_count
            },
            pending_online_orders: Order.pending_fulfillment.count,
            new_online_orders: Order.active_sales.order_status_order.count,
            recent_transactions: recent_transactions.map { |transaction| json.pos_transaction(transaction) },
            recent_orders: recent_orders.map { |order| json.order(order) }
          })
        end
      end
    end
  end
end
