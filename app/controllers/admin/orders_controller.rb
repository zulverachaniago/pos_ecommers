# frozen_string_literal: true

class Admin::OrdersController < ApplicationController
  layout "admin"
  before_action :set_order, only: [:show, :update]

  def index
    authorize Order
    scope = Order.includes(:customer)
                 .order(created_at: :desc)
    @orders = paginate_scope(scope)
  end

  def show
    authorize @order
    @status_records = @order.order_status_records.chronological.includes(user: :customer)
    @next_statuses = next_available_statuses(@order)
  end

  def update
    authorize @order
    new_status = params.dig(:order, :order_status)
    notes = params.dig(:order, :notes)

    if @order.update_order_status!(new_status, user: current_user, notes: notes.presence)
      redirect_to admin_order_path(@order), notice: "Status pesanan diperbarui."
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
