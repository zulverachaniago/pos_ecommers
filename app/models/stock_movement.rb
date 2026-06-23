# frozen_string_literal: true

class StockMovement < ApplicationRecord
  belongs_to :product_variant
  belongs_to :user
  belongs_to :referenceable, polymorphic: true, optional: true

  enum :movement_type, {
    stock_in: 0,
    adjustment: 1,
    stock_out: 2,
    pos_sale: 3,
    order_sale: 4
  }

  MOVEMENT_TYPE_LABELS = {
    "stock_in" => "Penambahan Stok",
    "adjustment" => "Penyesuaian Stok",
    "stock_out" => "Pengeluaran Stok",
    "pos_sale" => "Penjualan POS",
    "order_sale" => "Penjualan Online"
  }.freeze

  MANUAL_TYPES = %w[stock_in adjustment stock_out].freeze

  validates :movement_type, presence: true
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validate :quantity_sign_matches_type, if: -> { movement_type.present? }

  scope :recent, -> { order(created_at: :desc) }
  scope :manual, -> { where(movement_type: MANUAL_TYPES) }

  def movement_type_label
    MOVEMENT_TYPE_LABELS[movement_type] || movement_type.to_s.humanize
  end

  def reference_label
    return notes if referenceable.blank?

    case referenceable
    when PosTransaction
      referenceable.transaction_number
    when Order
      referenceable.order_number
    when User
      "Manual — #{referenceable.email}"
    else
      "#{referenceable_type} ##{referenceable_id}"
    end
  end

  def quantity_label
    prefix = quantity.positive? ? "+" : ""
    "#{prefix}#{quantity}"
  end

  private

  def quantity_sign_matches_type
    case movement_type
    when "stock_in"
      errors.add(:quantity, "harus positif") if quantity.negative?
    when "stock_out", "pos_sale", "order_sale"
      errors.add(:quantity, "harus negatif") if quantity.positive?
    end
  end
end
