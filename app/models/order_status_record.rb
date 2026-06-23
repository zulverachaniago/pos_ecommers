# frozen_string_literal: true

class OrderStatusRecord < ApplicationRecord
  belongs_to :order
  belongs_to :user, optional: true

  enum :order_status, { order: 1, process: 2, ship: 3, done: 4 }, prefix: true

  validates :order_status, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  def status_label
    Order::ORDER_STATUS_LABELS[order_status] || order_status.to_s.humanize
  end

  def actor_name
    return "Sistem" unless user

    user.customer&.name.presence || user.email
  end
end
