# frozen_string_literal: true

class Admin::StockMovementsController < ApplicationController
  layout "admin"
  before_action :set_movement_type, only: [:new, :create]

  def index
    authorize StockMovement
    scope = StockMovement.includes(:user, :product_variant, :referenceable, product_variant: :product)
                         .recent
    scope = scope.where(movement_type: params[:type]) if params[:type].present? && StockMovement.movement_types.key?(params[:type])
    @movements = paginate_scope(scope)
  end

  def new
    authorize StockMovement
    @movement = StockMovement.new(movement_type: @movement_type)
    load_variants
  end

  def create
    authorize StockMovement
    @movement = StockMovement.new(stock_movement_params)
    @movement.user = current_user

    begin
      StockMovementRecorder.record_manual!(
        variant: ProductVariant.find(stock_movement_params[:product_variant_id]),
        quantity: stock_movement_params[:quantity],
        movement_type: @movement_type,
        user: current_user,
        notes: stock_movement_params[:notes]
      )
      redirect_to admin_stock_movements_path, notice: "#{StockMovement::MOVEMENT_TYPE_LABELS[@movement_type]} berhasil dicatat."
    rescue StockMovementRecorder::InsufficientStockError => e
      flash.now[:alert] = e.message
      @movement = StockMovement.new(stock_movement_params)
      load_variants
      render :new, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      @movement = StockMovement.new(stock_movement_params)
      load_variants
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_movement_type
    @movement_type = params[:type].presence || params.dig(:stock_movement, :movement_type)
    @movement_type = "stock_in" unless StockMovement::MANUAL_TYPES.include?(@movement_type)
  end

  def load_variants
    @variants = ProductVariant.joins(:product)
                              .where(products: { is_active: true })
                              .includes(:product)
                              .order("products.name")
  end

  def stock_movement_params
    params.require(:stock_movement).permit(:product_variant_id, :quantity, :notes, :movement_type)
  end
end
