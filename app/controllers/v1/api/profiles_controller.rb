# frozen_string_literal: true

module V1
  module Api
    class ProfilesController < BaseController
      def show
        render_success(json.user(current_user))
      end

      def update
        if password_change? && !current_user.valid_password?(params[:current_password].to_s)
          render_error("Password saat ini salah.")
          return
        end

        unless current_user.update(user_params)
          render_invalid(current_user)
          return
        end

        if current_user.has_role?(:customer)
          customer = current_customer
          unless customer.update(customer_params)
            render_invalid(customer)
            return
          end
        end

        render_success(json.user(current_user.reload), message: "Profil berhasil diperbarui.")
      end

      private

      def password_change?
        params.dig(:user, :password).present? || params[:password].present?
      end

      def user_params
        source = params[:user].presence || ActionController::Parameters.new
        permitted = source.permit(:email, :password, :password_confirmation)
        if permitted[:password].blank?
          permitted.delete(:password)
          permitted.delete(:password_confirmation)
        end
        permitted
      end

      def customer_params
        source = params[:customer].presence || params
        source.permit(:name, :phone, :address, :customer_type)
      end
    end
  end
end
