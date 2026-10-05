# frozen_string_literal: true

module V1
  module Api
    module Owner
      class ReportsController < BaseController
        before_action :require_owner!
        before_action :set_date_range, only: :sales

        def sales
          report = SalesReport.new(range: @range)
          entries = paginate_scope(Kaminari.paginate_array(report.sorted_entries))

          render_collection(entries, {
            summary: {
              start_date: @start_date,
              end_date: @end_date,
              total_sales: report.total_sales.to_f,
              pos_sales: report.pos_total.to_f,
              online_sales: report.online_total.to_f,
              count: report.count,
              pos_count: report.pos_count,
              online_count: report.online_count
            },
            entries: entries.map { |entry| sales_entry(entry) }
          })
        end

        def stock
          online_demand = OrderItem.joins(:order).merge(Order.pending_fulfillment).group(:product_variant_id).sum(:quantity)
          totals = StockInventory.totals_hash
          scope = ProductVariant.includes(product: [:category, :supplier]).order("products.name")
          variants = paginate_scope(scope)

          render_collection(variants, {
            pending_online_orders: Order.pending_fulfillment.count,
            stock: stock_health_counts,
            rows: variants.map { |variant| stock_row(variant, totals, online_demand) }
          })
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

        def sales_entry(entry)
          {
            source: entry.source,
            number: entry.number,
            occurred_at: entry.occurred_at,
            customer_name: entry.customer_name,
            staff: entry.staff,
            payment_method: entry.payment_method,
            status: entry.status,
            total_amount: entry.total_amount.to_f
          }
        end

        def stock_row(variant, totals, online_demand)
          product = variant.product
          snapshot = StockInventory.variant_snapshot(variant, totals: totals, reserved: online_demand[variant.id].to_i)
          status_label = case snapshot[:status]
          when :out then "Habis"
          when :low then "Rendah"
          else "Aman"
          end

          {
            variant_id: variant.id,
            sku: product.sku,
            product: product.name,
            variant: variant.variant_name,
            category: product.category&.name,
            supplier: product.supplier&.name,
            unit: variant.unit,
            stock: snapshot[:on_hand],
            reserved: snapshot[:reserved],
            available: snapshot[:available],
            minimum: snapshot[:minimum],
            status: status_label,
            status_key: snapshot[:status]
          }
        end
      end
    end
  end
end
