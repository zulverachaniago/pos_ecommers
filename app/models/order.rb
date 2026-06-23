# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :courier, class_name: "User", optional: true
  has_many :order_items, dependent: :destroy
  has_many :order_status_records, dependent: :destroy

  enum :status, [:pending, :confirmed, :processing, :delivered, :cancelled]
  enum :order_status, { order: 1, process: 2, ship: 3, done: 4 }, prefix: true
  enum :payment_method, { cod: 1, transfer: 2 }, prefix: true

  ORDER_STATUS_LABELS = {
    "order" => "Order",
    "process" => "Proses",
    "ship" => "Kirim",
    "done" => "Selesai"
  }.freeze

  PAYMENT_METHOD_LABELS = {
    "cod" => "Cash on Delivery (COD)",
    "transfer" => "Transfer Bank"
  }.freeze

  before_create :assign_order_defaults

  validates :order_number, uniqueness: true, allow_nil: true

  scope :active_sales, -> { where.not(status: :cancelled) }
  scope :pending_fulfillment, -> { active_sales.where.not(order_status: :done) }
  scope :ready_for_courier, -> { active_sales.order_status_process }
  scope :courier_active, ->(user) { where(courier_id: user.id).where(order_status: [:ship, :done]) }
  scope :search_by_number, ->(query) {
    sanitized = query.to_s.strip
    sanitized.present? ? where("order_number ILIKE ?", "%#{sanitize_sql_like(sanitized)}%") : all
  }

  def order_status_label
    ORDER_STATUS_LABELS[order_status] || order_status.to_s.humanize
  end

  def payment_method_label
    PAYMENT_METHOD_LABELS[payment_method] || payment_method.to_s.humanize
  end

  def record_order_status!(user:, notes: nil)
    order_status_records.create!(
      order_status: order_status,
      user: user,
      notes: notes
    )
  end

  def update_order_status!(new_status, user:, notes: nil)
    new_status = new_status.to_sym
    return false if order_status.to_sym == new_status
    return false unless self.class.order_statuses.key?(new_status.to_s)

    transaction do
      update!(order_status: new_status)
      order_status_records.create!(
        order_status: new_status,
        user: user,
        notes: notes
      )
      if new_status == :done
        begin
          StockMovementRecorder.deduct_for_order!(self, user: user)
        rescue StockMovementRecorder::InsufficientStockError => e
          errors.add(:base, e.message)
          raise ActiveRecord::Rollback
        end
      end
    end

    return false if errors[:base].any?

    true
  end

  def pickup_by_courier!(courier, notes: nil)
    return false unless order_status_process?

    transaction do
      update!(courier_id: courier.id)
      update_order_status!(:ship, user: courier, notes: notes.presence || "Pesanan diambil kurir")
    end
  end

  def complete_by_courier!(courier, notes: nil)
    return false unless order_status_ship?
    return false unless courier_id == courier.id

    update_order_status!(:done, user: courier, notes: notes.presence || "Pesanan selesai dikirim")
  end

  private

  def assign_order_defaults
    self.order_date ||= Time.zone.now
    self.order_status ||= :order
    self.payment_method ||= :cod
    self.status ||= :pending
    self.order_number ||= generate_order_number
  end

  def generate_order_number
    loop do
      number = "ORD-#{Time.zone.now.strftime('%Y%m%d%H%M')}-#{SecureRandom.hex(2).upcase}"
      break number unless Order.exists?(order_number: number)
    end
  end
end
