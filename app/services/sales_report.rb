# frozen_string_literal: true

class SalesReport
  SalesEntry = Struct.new(
    :source, :number, :occurred_at, :customer_name, :staff, :payment_method, :status, :total_amount,
    keyword_init: true
  )

  def initialize(range:)
    @range = range
  end

  def sorted_entries
    (pos_entries + online_entries).sort_by(&:occurred_at).reverse
  end

  def total_sales
    sorted_entries.sum(&:total_amount).to_d
  end

  def pos_total
    pos_entries.sum(&:total_amount).to_d
  end

  def online_total
    online_entries.sum(&:total_amount).to_d
  end

  def count
    sorted_entries.size
  end

  def pos_count
    pos_entries.size
  end

  def online_count
    online_entries.size
  end

  private

  def pos_entries
    PosTransaction.includes(:customer, :user)
                  .where(created_at: @range)
                  .map do |tx|
      SalesEntry.new(
        source: "POS",
        number: tx.transaction_number,
        occurred_at: tx.created_at,
        customer_name: tx.customer&.name || "Pelanggan Umum",
        staff: tx.user&.email,
        payment_method: tx.payment_method.to_s.humanize,
        status: tx.payment_status.to_s.humanize,
        total_amount: tx.total_amount.to_d
      )
    end
  end

  def online_entries
    Order.active_sales.includes(:customer)
         .where(created_at: @range)
         .map do |order|
      SalesEntry.new(
        source: "Online",
        number: order.order_number,
        occurred_at: order.order_date || order.created_at,
        customer_name: order.customer.name,
        staff: "-",
        payment_method: order.payment_method_label,
        status: order.order_status_label,
        total_amount: order.total_amount.to_d
      )
    end
  end
end
