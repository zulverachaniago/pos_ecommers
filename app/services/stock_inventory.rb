# frozen_string_literal: true

class StockInventory
  STATUS_LABELS = {
    available: { label: "Tersedia", badge_class: "bg-emerald-100 text-emerald-700" },
    low: { label: "Stok Menipis", badge_class: "bg-amber-100 text-amber-700" },
    out: { label: "Habis", badge_class: "bg-red-100 text-red-700" }
  }.freeze

  class << self
    def totals_hash(variant_ids = nil)
      totals = StockMovement.group(:product_variant_id).sum(:quantity)
      return totals if variant_ids.blank?

      totals.slice(*Array(variant_ids).map(&:to_i))
    end

    def on_hand(variant, totals: nil)
      return totals.fetch(variant.id, 0).to_i if totals

      variant.current_stock
    end

    def status(on_hand, minimum = 0)
      return :out if on_hand.to_i <= 0
      return :low if minimum.to_i.positive? && on_hand.to_i <= minimum.to_i

      :available
    end

    def status_label(status_key)
      STATUS_LABELS.fetch(status_key, STATUS_LABELS[:out])[:label]
    end

    def status_badge_class(status_key)
      STATUS_LABELS.fetch(status_key, STATUS_LABELS[:out])[:badge_class]
    end

    def variant_snapshot(variant, totals:, reserved: 0)
      on_hand_qty = on_hand(variant, totals: totals)
      minimum = variant.stock_minimum.to_i
      reserved_qty = reserved.to_i
      available = [on_hand_qty - reserved_qty, 0].max

      {
        on_hand: on_hand_qty,
        available: available,
        reserved: reserved_qty,
        minimum: minimum,
        unit: variant.unit,
        status: status(on_hand_qty, minimum),
        availability_status: status(available, minimum)
      }
    end

    def product_summary(variants, totals:)
      stocks = variants.map { |variant| on_hand(variant, totals: totals) }
      return empty_product_summary if stocks.empty?

      in_stock_variants = variants.zip(stocks).select { |_, qty| qty.positive? }
      minimums = variants.map { |v| v.stock_minimum.to_i }
      worst_status = variants.zip(stocks, minimums).map { |v, qty, min| status(qty, min) }
                                 .max_by { |s| %i[out low available].index(s) }

      label =
        if variants.size == 1
          format_quantity(stocks.first, variants.first.unit)
        elsif in_stock_variants.empty?
          "Habis"
        else
          min_qty = stocks.min
          max_qty = stocks.max
          min_qty == max_qty ? format_quantity(min_qty, variants.first.unit) : "Stok #{min_qty}–#{max_qty}"
        end

      {
        label: label,
        total: stocks.sum,
        in_stock_count: in_stock_variants.size,
        variant_count: variants.size,
        status: worst_status
      }
    end

    def low_stock_variant_ids(totals: nil)
      totals ||= totals_hash
      ProductVariant.find_each.filter_map do |variant|
        qty = on_hand(variant, totals: totals)
        variant.id if status(qty, variant.stock_minimum.to_i) != :available
      end
    end

    def format_quantity(qty, unit = nil)
      text = qty.to_i.to_s
      unit.present? ? "#{text} #{unit}" : text
    end

    private

    def empty_product_summary
      {
        label: "—",
        total: 0,
        in_stock_count: 0,
        variant_count: 0,
        status: :out
      }
    end
  end
end
