class Pos::DashboardController < Pos::BaseController
  def index
    authorize :dashboard, :index?

    today = Time.zone.today.all_day
    week_range = Time.zone.today.beginning_of_week..Time.zone.today.end_of_day
    @today_metrics = SalesMetrics.new(today)
    @week_metrics = SalesMetrics.new(week_range)

    @pending_online_orders = Order.pending_fulfillment.count
    @new_online_orders = Order.active_sales.order_status_order.count

    @recent_transactions = PosTransaction.includes(:customer, :user)
                                         .order(created_at: :desc)
                                         .limit(5)
    @recent_online_orders = Order.active_sales
                                 .includes(:customer)
                                 .order(created_at: :desc)
                                 .limit(5)
  end
end
