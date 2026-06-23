# frozen_string_literal: true

class StockMovementRecorder
  class InsufficientStockError < StandardError; end

  def self.record!(variant:, quantity:, movement_type:, user:, referenceable: nil, notes: nil, allow_negative: false)
    new(
      variant: variant,
      quantity: quantity,
      movement_type: movement_type,
      user: user,
      referenceable: referenceable,
      notes: notes,
      allow_negative: allow_negative
    ).call
  end

  def self.record_manual!(variant:, quantity:, movement_type:, user:, notes: nil)
    normalized_qty = normalize_manual_quantity(quantity, movement_type)
    record!(
      variant: variant,
      quantity: normalized_qty,
      movement_type: movement_type,
      user: user,
      referenceable: user,
      notes: notes,
      allow_negative: movement_type.to_sym == :adjustment
    )
  end

  def self.deduct_for_pos!(transaction)
    return if transaction.payment_status != "paid"

    transaction.pos_transaction_items.each do |item|
      next if StockMovement.exists?(
        referenceable: transaction,
        movement_type: :pos_sale,
        product_variant_id: item.product_variant_id
      )

      record!(
        variant: item.product_variant,
        quantity: -item.quantity,
        movement_type: :pos_sale,
        user: transaction.user,
        referenceable: transaction,
        notes: "Penjualan POS #{transaction.transaction_number}"
      )
    end
  end

  def self.deduct_for_order!(order, user:)
    return unless order.order_status_done?

    order.order_items.includes(:product_variant).each do |item|
      next if StockMovement.exists?(
        referenceable: order,
        movement_type: :order_sale,
        product_variant_id: item.product_variant_id
      )

      record!(
        variant: item.product_variant,
        quantity: -item.quantity,
        movement_type: :order_sale,
        user: user,
        referenceable: order,
        notes: "Pesanan online #{order.order_number} selesai"
      )
    end
  end

  def self.normalize_manual_quantity(quantity, movement_type)
    qty = quantity.to_i
    case movement_type.to_sym
    when :stock_in
      qty.abs
    when :stock_out
      -qty.abs
    else
      qty
    end
  end

  def initialize(variant:, quantity:, movement_type:, user:, referenceable: nil, notes: nil, allow_negative: false)
    @variant = variant
    @quantity = quantity.to_i
    @movement_type = movement_type
    @user = user
    @referenceable = referenceable
    @notes = notes
    @allow_negative = allow_negative
  end

  def call
    stock_before = @variant.current_stock
    stock_after = stock_before + @quantity

    unless @allow_negative || stock_after >= 0
      raise InsufficientStockError,
            "Stok #{@variant.display_name} tidak mencukupi (tersedia: #{stock_before}, keluar: #{@quantity.abs})"
    end

    StockMovement.create!(
      product_variant: @variant,
      user: @user,
      movement_type: @movement_type,
      quantity: @quantity,
      stock_before: stock_before,
      stock_after: stock_after,
      referenceable: @referenceable,
      notes: @notes
    )
  end
end
