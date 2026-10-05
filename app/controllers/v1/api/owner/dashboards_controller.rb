# frozen_string_literal: true

module V1
  module Api
    module Owner
      class DashboardsController < BaseController
        before_action :require_owner!

        def show
          today = SalesMetrics.new(Time.zone.today.all_day)
          month = SalesMetrics.new(Time.zone.today.beginning_of_month..Time.zone.today.end_of_day)
          activities = SalesMetrics.new(30.days.ago.beginning_of_day..Time.zone.now).recent_activities(limit: 8)
          daily = SalesMetrics.new(6.days.ago.beginning_of_day..Time.zone.today.end_of_day)
                              .daily_combined_sales(from_date: 6.days.ago.to_date, to_date: Time.zone.today)

          render_success({
            today: { total: today.combined_sales.to_f, count: today.combined_count },
            month: {
              total: month.combined_sales.to_f,
              pos: month.pos_sales.to_f,
              online: month.online_sales.to_f,
              count: month.combined_count
            },
            customers: Customer.count,
            suppliers: Supplier.count,
            pending_online_orders: Order.pending_fulfillment.count,
            new_online_orders: Order.order_status_order.count,
            stock: stock_health_counts,
            recent_activities: activities.map { |activity| activity_json(activity) },
            daily_sales: daily.map { |date, amount| { date: date, total: amount.to_f } }
          })
        end

        private

        def activity_json(activity)
          {
            kind: activity.kind,
            reference: activity.reference,
            customer_name: activity.customer_name,
            amount: activity.amount.to_f,
            occurred_at: activity.occurred_at,
            status_label: activity.status_label
          }
        end
      end
    end
  end
end
