# frozen_string_literal: true

module StockHelper
  def stock_status_badge(status, compact: false)
    config = StockInventory::STATUS_LABELS.fetch(status, StockInventory::STATUS_LABELS[:out])
    size_class = compact ? "px-2 py-0.5 text-[10px]" : "px-2.5 py-1 text-xs"
    tag.span(
      config[:label],
      class: "inline-flex items-center font-semibold rounded-full #{size_class} #{config[:badge_class]}"
    )
  end

  def stock_quantity_label(qty, unit = nil)
    StockInventory.format_quantity(qty, unit)
  end
end
