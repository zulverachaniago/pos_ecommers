# frozen_string_literal: true

class Pos::OrdersController < Pos::BaseController
  before_action :set_order, only: [:show, :update, :shipping_slip]

  def index
    authorize Order
    @filter = params[:filter].presence || "pending"
    scope = Order.includes(:customer).order(created_at: :desc)
    scope = scope.where.not(order_status: :done) if @filter == "pending"
    @pending_count = Order.where.not(order_status: :done).count
    @orders = paginate_scope(scope)
  end

  def show
    authorize @order
    @status_records = @order.order_status_records.chronological.includes(user: :customer)
    @next_statuses = next_available_statuses(@order)
  end

  def shipping_slip
    authorize @order, :shipping_slip?
    return if @order.order_status_process? || @order.order_status_ship? || @order.order_status_done?

    redirect_to pos_order_path(@order), alert: "Label pengiriman tersedia setelah pesanan diproses."
  end

  def update
    authorize @order
    new_status = params.dig(:order, :order_status)
    notes = params.dig(:order, :notes)
    payment_method = params.dig(:order, :payment_method)

    if payment_method.present?
      @order.update!(payment_method: payment_method)
    end

    if @order.update_order_status!(new_status, user: current_user, notes: notes.presence)
      if new_status.to_s == "process"
        redirect_to shipping_slip_pos_order_path(@order), notice: "Pesanan diproses. Cetak label pengiriman."
      else
        redirect_to pos_order_path(@order, filter: params[:filter]), notice: "Status pesanan diperbarui."
      end
    elsif @order.errors[:base].any?
      @status_records = @order.order_status_records.chronological.includes(user: :customer)
      @next_statuses = next_available_statuses(@order)
      flash.now[:alert] = @order.errors[:base].to_sentence
      render :show, status: :unprocessable_entity
    else
      @status_records = @order.order_status_records.chronological.includes(user: :customer)
      @next_statuses = next_available_statuses(@order)
      flash.now[:alert] = "Status tidak berubah atau tidak valid."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.includes(
      :customer,
      order_items: { product_variant: :product },
      order_status_records: { user: :customer }
    ).find(params[:id])
  end

  def next_available_statuses(order)
    current_step = Order.order_statuses[order.order_status]
    next_status = Order.order_statuses.key(current_step + 1)
    next_status ? [next_status] : []
  end
end
