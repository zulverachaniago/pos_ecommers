# frozen_string_literal: true

module V1
  module Api
    module Admin
      class DashboardsController < BaseController
        def show
          authorize :dashboard, :index?

          today = SalesMetrics.new(Time.zone.today.all_day)
          health = stock_health_counts

          render_success({
            sales_today: {
              total: today.combined_sales.to_f,
              pos: today.pos_sales.to_f,
              online: today.online_sales.to_f,
              pos_count: today.pos_count,
              online_count: today.online_count
            },
            catalog: {
              products: Product.count,
              active_products: Product.where(is_active: true).count,
              categories: Category.count,
              variants: ProductVariant.count,
              suppliers: Supplier.count,
              customers: Customer.count
            },
            orders: {
              pending: Order.order_status_order.count,
              processing: Order.active_sales.where(order_status: [:process, :ship]).count
            },
            stock: health
          })
        end
      end
    end
  end
end
