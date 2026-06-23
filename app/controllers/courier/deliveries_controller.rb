# frozen_string_literal: true

class Courier::DeliveriesController < Courier::BaseController
  before_action :set_order, only: [:show, :pickup]

  def index
    authorize Order, policy_class: Courier::DeliveryPolicy

    scope = Order.ready_for_courier
                 .includes(:customer, order_items: { product_variant: :product })
                 .order(created_at: :asc)
    scope = scope.search_by_number(params[:q]) if params[:q].present?

    if params[:q].present? && scope.one?
      redirect_to courier_delivery_path(scope.first, q: params[:q]) and return
    end

    @orders = paginate_scope(scope)
    @ready_count = Order.ready_for_courier.count
  end

  def show
    authorize @order, policy_class: Courier::DeliveryPolicy
  end

  def pickup
    authorize @order, :pickup?, policy_class: Courier::DeliveryPolicy

    notes = params.dig(:order, :notes)
    if @order.pickup_by_courier!(current_user, notes: notes)
      redirect_to courier_completed_path(@order), notice: "Pesanan #{@order.order_number} siap dikirim."
    else
      redirect_to courier_delivery_path(@order), alert: "Pesanan tidak dapat diambil."
    end
  end

  private

  def set_order
    @order = Order.includes(:customer, :courier, order_items: { product_variant: :product })
                  .find(params[:id])
  end
end
