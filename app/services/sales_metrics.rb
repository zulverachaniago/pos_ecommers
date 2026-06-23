# frozen_string_literal: true

class SalesMetrics
  def initialize(range)
    @range = range
  end

  def pos_sales
    @pos_sales ||= pos_transactions.sum(:total_amount).to_d
  end

  def online_sales
    @online_sales ||= online_orders.sum(:total_amount).to_d
  end

  def combined_sales
    pos_sales + online_sales
  end

  def pos_count
    @pos_count ||= pos_transactions.count
  end

  def online_count
    @online_count ||= online_orders.count
  end

  def combined_count
    pos_count + online_count
  end

  def daily_combined_sales(from_date:, to_date:)
    range = from_date.beginning_of_day..to_date.end_of_day
    pos_daily = PosTransaction.where(created_at: range)
                                .group_by_day(:created_at, time_zone: Time.zone)
                                .sum(:total_amount)
    online_daily = Order.active_sales.where(created_at: range)
                        .group_by_day(:created_at, time_zone: Time.zone)
                        .sum(:total_amount)

    (from_date..to_date).index_with do |date|
      pos_daily[date].to_d + online_daily[date].to_d
    end
  end

  def recent_activities(limit: 8)
    pos_items = pos_transactions
                .includes(:customer, :user)
                .order(created_at: :desc)
                .limit(limit)
                .map { |tx| activity_from_pos(tx) }

    order_items = online_orders
                  .includes(:customer)
                  .order(created_at: :desc)
                  .limit(limit)
                  .map { |order| activity_from_order(order) }

    (pos_items + order_items)
      .sort_by { |item| item.occurred_at }
      .reverse
      .first(limit)
  end

  private

  def pos_transactions
    PosTransaction.where(created_at: @range)
  end

  def online_orders
    Order.active_sales.where(created_at: @range)
  end

  def activity_from_pos(tx)
    SalesActivity.new(
      kind: "POS",
      reference: tx.transaction_number,
      customer_name: tx.customer&.name || "Pelanggan Umum",
      amount: tx.total_amount.to_d,
      occurred_at: tx.created_at,
      path: "/pos/transactions/#{tx.id}",
      status_label: tx.payment_status.to_s.humanize
    )
  end

  def activity_from_order(order)
    SalesActivity.new(
      kind: "Online",
      reference: order.order_number,
      customer_name: order.customer.name,
      amount: order.total_amount.to_d,
      occurred_at: order.order_date || order.created_at,
      path: "/pos/orders/#{order.id}",
      status_label: order.order_status_label
    )
  end
end

SalesActivity = Struct.new(
  :kind, :reference, :customer_name, :amount, :occurred_at, :path, :status_label,
  keyword_init: true
)
