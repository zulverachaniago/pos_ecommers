# frozen_string_literal: true

class Owner::ReportsController < Owner::BaseController
  before_action :set_date_range, only: :sales

  def sales
    authorize :report, :index?, policy_class: Owner::ReportPolicy

    @report = SalesReport.new(range: @range)
    @total_sales = @report.total_sales
    @pos_sales = @report.pos_total
    @online_sales = @report.online_total
    @transaction_count = @report.count
    @pos_count = @report.pos_count
    @online_count = @report.online_count

    respond_to do |format|
      format.html do
        @sales_entries = paginate_scope(Kaminari.paginate_array(@report.sorted_entries))
      end
      format.csv do
        rows = @report.sorted_entries.map { |entry| sales_row_values(entry) }
        send_export_csv("report-penjualan-#{@start_date}-#{@end_date}", sales_headers, rows)
      end
      format.xls do
        rows = @report.sorted_entries.map { |entry| sales_row_values(entry) }
        send_export_xls("report-penjualan-#{@start_date}-#{@end_date}", sales_headers, rows)
      end
      format.xlsx do
        rows = @report.sorted_entries.map { |entry| sales_row_values(entry) }
        send_export_xls("report-penjualan-#{@start_date}-#{@end_date}", sales_headers, rows)
      end
    end
  end

  def stock
    authorize :report, :index?, policy_class: Owner::ReportPolicy

    @online_demand = online_demand_by_variant
    @pending_online_orders = Order.pending_fulfillment.count
    @stock_totals = StockInventory.totals_hash
    @low_stock_count = ProductVariant.find_each.count do |variant|
      qty = StockInventory.on_hand(variant, totals: @stock_totals)
      StockInventory.status(qty, variant.stock_minimum.to_i) == :low
    end
    @out_of_stock_count = ProductVariant.find_each.count do |variant|
      StockInventory.on_hand(variant, totals: @stock_totals) <= 0
    end

    scope = ProductVariant.includes(product: [:category, :supplier]).order("products.name")

    respond_to do |format|
      format.html do
        @variants = paginate_scope(scope)
        @stock_rows = @variants.map { |variant| stock_row_for(variant) }
      end
      format.csv do
        rows = scope.map { |variant| stock_row_values(stock_row_for(variant)) }
        send_export_csv("report-stok-#{Date.current}", stock_headers, rows)
      end
      format.xls do
        rows = scope.map { |variant| stock_row_values(stock_row_for(variant)) }
        send_export_xls("report-stok-#{Date.current}", stock_headers, rows)
      end
      format.xlsx do
        rows = scope.map { |variant| stock_row_values(stock_row_for(variant)) }
        send_export_xls("report-stok-#{Date.current}", stock_headers, rows)
      end
    end
  end

  private

  def set_date_range
    @start_date = parse_date(params[:start_date]) || Time.zone.today.beginning_of_month.to_date
    @end_date = parse_date(params[:end_date]) || Time.zone.today
    @range = @start_date.beginning_of_day..@end_date.end_of_day
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def online_demand_by_variant
    OrderItem.joins(:order)
             .merge(Order.pending_fulfillment)
             .group(:product_variant_id)
             .sum(:quantity)
  end

  def stock_row_for(variant)
    product = variant.product
    snapshot = StockInventory.variant_snapshot(
      variant,
      totals: @stock_totals,
      reserved: @online_demand[variant.id].to_i
    )

    status_label =
      case snapshot[:status]
      when :out then "Habis"
      when :low then "Rendah"
      else "Aman"
      end

    {
      sku: product.sku,
      product: product.name,
      variant: variant.variant_name,
      category: product.category&.name,
      supplier: product.supplier&.name,
      unit: variant.unit,
      stock: snapshot[:on_hand],
      available: snapshot[:available],
      minimum: snapshot[:minimum],
      reserved: snapshot[:reserved],
      status: status_label,
      status_key: snapshot[:status]
    }
  end

  def sales_headers
    ["Sumber", "No. Referensi", "Tanggal", "Pelanggan", "PIC", "Pembayaran", "Status", "Total (Rp)"]
  end

  def sales_row_values(entry)
    [
      entry.source,
      entry.number,
      entry.occurred_at.strftime("%d/%m/%Y %H:%M"),
      entry.customer_name,
      entry.staff,
      entry.payment_method,
      entry.status,
      entry.total_amount.to_i
    ]
  end

  def stock_headers
    ["SKU", "Produk", "Varian", "Kategori", "Supplier", "Satuan", "Stok Fisik", "Pesanan Online", "Stok Tersedia", "Stok Minimum", "Status"]
  end

  def stock_row_values(row)
    [row[:sku], row[:product], row[:variant], row[:category], row[:supplier],
     row[:unit], row[:stock], row[:reserved], row[:available], row[:minimum], row[:status]]
  end
end
