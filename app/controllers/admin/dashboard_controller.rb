class Admin::DashboardController < ApplicationController
  layout "admin"

  def index
    authorize :dashboard, :index?

    today = Time.zone.today.all_day
    @today_metrics = SalesMetrics.new(today)

    @total_products = Product.count
    @active_products = Product.where(is_active: true).count
    @total_categories = Category.count
    @total_variants = ProductVariant.count
    @total_suppliers = Supplier.count
    @total_customers = Customer.count

    @pending_orders = Order.order_status_order.count
    @processing_orders = Order.active_sales.where(order_status: [:process, :ship]).count
    @online_orders_today = @today_metrics.online_count

    @recent_online_orders = Order.active_sales
                                 .includes(:customer)
                                 .order(created_at: :desc)
                                 .limit(5)

    @stock_totals = StockInventory.totals_hash
    @low_stock_count = ProductVariant.find_each.count do |variant|
      qty = StockInventory.on_hand(variant, totals: @stock_totals)
      StockInventory.status(qty, variant.stock_minimum.to_i) == :low
    end
    @out_of_stock_count = ProductVariant.find_each.count do |variant|
      StockInventory.on_hand(variant, totals: @stock_totals) <= 0
    end
  end
end
