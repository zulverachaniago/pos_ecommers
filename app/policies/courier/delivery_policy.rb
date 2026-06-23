# frozen_string_literal: true

class Courier::DeliveryPolicy < ApplicationPolicy
  def index?
    courier?
  end

  def show?
    courier?
  end

  def pickup?
    courier? && record.order_status_process?
  end

  def finish?
    courier? && record.order_status_ship? && record.courier_id == user.id
  end

  private

  def courier?
    user.has_role?(:courier)
  end
end
