# frozen_string_literal: true

class Courier::CompletedController < Courier::BaseController
  before_action :set_order, only: [:show, :finish]

  def index
    authorize Order, policy_class: Courier::DeliveryPolicy

    scope = Order.courier_active(current_user)
                 .includes(:customer, order_items: { product_variant: :product })
                 .order(updated_at: :desc)
    scope = scope.search_by_number(params[:q]) if params[:q].present?

    @orders = paginate_scope(scope)
    @delivering_count = Order.where(courier_id: current_user.id, order_status: :ship).count
    @done_count = Order.where(courier_id: current_user.id, order_status: :done).count
  end

  def show
    authorize @order, policy_class: Courier::DeliveryPolicy
  end

  def finish
    authorize @order, :finish?, policy_class: Courier::DeliveryPolicy

    notes = params.dig(:order, :notes)
    if @order.complete_by_courier!(current_user, notes: notes)
      redirect_to courier_completed_index_path, notice: "Pesanan #{@order.order_number} selesai dikirim."
    else
      alert = @order.errors[:base].to_sentence.presence || "Pesanan tidak dapat diselesaikan."
      redirect_to courier_completed_path(@order), alert: alert
    end
  end

  private

  def set_order
    @order = Order.includes(:customer, :courier, order_items: { product_variant: :product })
                  .where(courier_id: current_user.id)
                  .find(params[:id])
  end
end
