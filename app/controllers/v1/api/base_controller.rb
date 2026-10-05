# frozen_string_literal: true

module V1
  module Api
    class BaseController < ActionController::API
      include Pundit::Authorization
      include Paginatable
      include ActiveStorage::SetCurrent

      TOKEN_PURPOSE = :api
      TOKEN_TTL = 30.days

      before_action :authenticate_api_user!

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private

      def authenticate_api_user!
        return if current_user

        render_error("Token tidak valid atau sudah kedaluwarsa.", status: :unauthorized)
      end

      def current_user
        return @current_user if defined?(@current_user)

        @current_user = User.find_signed(bearer_token, purpose: TOKEN_PURPOSE) if bearer_token.present?
      end

      def bearer_token
        header = request.authorization.to_s
        return unless header.start_with?("Bearer ")

        header.delete_prefix("Bearer ").presence
      end

      def issue_token(user)
        user.signed_id(purpose: TOKEN_PURPOSE, expires_in: TOKEN_TTL)
      end

      def json
        @json ||= JsonBuilder.new(self)
      end

      def render_success(data = nil, message: nil, status: :ok, meta: nil)
        body = { success: true }
        body[:message] = message if message.present?
        body[:data] = data unless data.nil?
        body[:meta] = meta if meta.present?
        render json: body, status: status
      end

      def render_collection(records, payload)
        render_success(payload, meta: pagination_meta(records))
      end

      def render_invalid(record, message: "Data tidak valid.")
        render_error(message, status: :unprocessable_entity, errors: record.errors.full_messages)
      end

      def render_error(message, status: :unprocessable_entity, errors: nil)
        body = { success: false, message: message }
        body[:errors] = errors if errors.present?
        render json: body, status: status
      end

      def render_forbidden
        render_error("Anda tidak memiliki akses untuk melakukan tindakan ini.", status: :forbidden)
      end

      def render_not_found
        render_error("Data tidak ditemukan.", status: :not_found)
      end

      def render_bad_request(exception)
        render_error(exception.message, status: :bad_request)
      end

      def pagination_meta(records)
        return unless records.respond_to?(:current_page)

        {
          page: records.current_page,
          per_page: records.limit_value,
          total_pages: records.total_pages,
          total_count: records.total_count
        }
      end

      def require_customer!
        return if current_user.has_role?(:customer) && current_customer

        render_forbidden
      end

      def require_owner!
        return if current_user.has_role?(:owner)

        render_forbidden
      end

      def require_courier!
        return if current_user.has_role?(:courier)

        render_forbidden
      end

      def current_customer
        @current_customer ||= current_user.customer || current_user.create_customer_profile
      end

      def current_cart
        current_customer.cart || current_customer.create_cart!
      end

      def staff?
        current_user.has_role?(:admin) || current_user.has_role?(:cashier) ||
          current_user.has_role?(:owner) || current_user.has_role?(:courier)
      end

      def stock_health_counts
        totals = StockInventory.totals_hash
        low = 0
        out = 0

        ProductVariant.find_each do |variant|
          qty = StockInventory.on_hand(variant, totals: totals)
          low += 1 if StockInventory.status(qty, variant.stock_minimum.to_i) == :low
          out += 1 if qty <= 0
        end

        { low_stock_count: low, out_of_stock_count: out }
      end

      def next_order_statuses(order)
        current_step = Order.order_statuses[order.order_status]
        next_status = Order.order_statuses.key(current_step + 1)
        next_status ? [ next_status ] : []
      end

      def order_includes
        [
          :customer,
          :courier,
          { order_items: { product_variant: :product } },
          { order_status_records: { user: :customer } }
        ]
      end
    end
  end
end
