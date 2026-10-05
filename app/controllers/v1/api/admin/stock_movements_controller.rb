# frozen_string_literal: true

module V1
  module Api
    module Admin
      class StockMovementsController < BaseController
        def index
          authorize StockMovement
          scope = StockMovement.includes(:user, product_variant: :product).recent
          if params[:type].present? && StockMovement.movement_types.key?(params[:type])
            scope = scope.where(movement_type: params[:type])
          end
          movements = paginate_scope(scope)
          render_collection(movements, movements.map { |movement| json.stock_movement(movement) })
        end

        def create
          authorize StockMovement
          movement_type = params[:type].presence || params.dig(:stock_movement, :movement_type)
          movement_type = "stock_in" unless StockMovement::MANUAL_TYPES.include?(movement_type)

          movement = StockMovementRecorder.record_manual!(
            variant: ProductVariant.find(stock_movement_params[:product_variant_id]),
            quantity: stock_movement_params[:quantity],
            movement_type: movement_type,
            user: current_user,
            notes: stock_movement_params[:notes]
          )
          movement = StockMovement.includes(:user, product_variant: :product).find(movement.id)

          render_success(json.stock_movement(movement), message: "#{StockMovement::MOVEMENT_TYPE_LABELS[movement_type]} berhasil dicatat.", status: :created)
        rescue StockMovementRecorder::InsufficientStockError => e
          render_error(e.message)
        rescue ActiveRecord::RecordInvalid => e
          render_invalid(e.record)
        end

        private

        def stock_movement_params
          params.require(:stock_movement).permit(:product_variant_id, :quantity, :notes, :movement_type)
        end
      end
    end
  end
end
