# frozen_string_literal: true

class Owner::DashboardController < Owner::BaseController
  def index
    authorize :dashboard, :index?, policy_class: Owner::DashboardPolicy

    today = Time.zone.today.all_day
    month_range = Time.zone.today.beginning_of_month..Time.zone.today.end_of_day

    @today_metrics = SalesMetrics.new(today)
    @month_metrics = SalesMetrics.new(month_range)

    @total_customers = Customer.count
    @total_suppliers = Supplier.count
    @pending_online_orders = Order.pending_fulfillment.count
    @new_online_orders = Order.order_status_order.count

    @stock_totals = StockInventory.totals_hash
    @low_stock_count = ProductVariant.find_each.count do |variant|
      qty = StockInventory.on_hand(variant, totals: @stock_totals)
      StockInventory.status(qty, variant.stock_minimum.to_i) == :low
    end
    @out_of_stock_count = ProductVariant.find_each.count do |variant|
      StockInventory.on_hand(variant, totals: @stock_totals) <= 0
    end

    @recent_activities = SalesMetrics.new(30.days.ago.beginning_of_day..Time.zone.now).recent_activities(limit: 8)

    chart_range = 6.days.ago.beginning_of_day..Time.zone.today.end_of_day
    @daily_sales = SalesMetrics.new(chart_range).daily_combined_sales(
      from_date: 6.days.ago.to_date,
      to_date: Time.zone.today
    )
  end
end
