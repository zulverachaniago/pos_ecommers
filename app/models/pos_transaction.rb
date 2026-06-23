class PosTransaction < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :user
  has_many :pos_transaction_items, dependent: :destroy

  accepts_nested_attributes_for :pos_transaction_items, allow_destroy: true, reject_if: :all_blank

  enum :payment_method, { cash: "cash", transfer: "transfer" }
  enum :payment_status, { pending: 0, paid: 1 }

  before_validation :calculate_total
  before_validation :set_amount_paid_for_transfer

  after_create_commit :record_stock_movements, if: :paid?

  validate :sufficient_stock_for_items, if: -> { paid? && pos_transaction_items.reject(&:marked_for_destruction?).any? }

  def change_amount
    return 0 unless amount_paid.present? && total_amount.present?

    [amount_paid - total_amount, 0].max
  end

  private

  def set_amount_paid_for_transfer
    return unless transfer? && amount_paid.blank?

    self.amount_paid = total_amount if total_amount.present?
  end

  def calculate_total
    items = pos_transaction_items.reject(&:marked_for_destruction?)
    self.total_amount = items.sum { |item| (item.quantity || 0) * (item.price_at_sale || 0) }
  end

  def sufficient_stock_for_items
    pos_transaction_items.reject(&:marked_for_destruction?).each do |item|
      next if item.product_variant.blank?

      available = item.product_variant.current_stock
      next if available >= item.quantity.to_i

      errors.add(:base, "Stok #{item.product_variant.display_name} tidak mencukupi (tersedia: #{available})")
    end
  end

  def record_stock_movements
    StockMovementRecorder.deduct_for_pos!(self)
  end
end
