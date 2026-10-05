# frozen_string_literal: true

module V1
  module Api
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: :create

      def create
        user = User.find_for_database_authentication(email: login_email)
        unless user&.valid_password?(login_password)
          render_error("Email atau password salah.", status: :unauthorized)
          return
        end

        unless portal_allowed?(user)
          render_error(portal_error_message, status: :forbidden)
          return
        end

        user.update_tracked_fields!(request) if user.respond_to?(:update_tracked_fields!)

        render_success(
          { token: issue_token(user), token_type: "Bearer", expires_in: TOKEN_TTL.to_i, user: json.user(user) },
          message: "Login berhasil."
        )
      end

      def destroy
        render_success(message: "Logout berhasil. Hapus token di aplikasi.")
      end

      private

      def login_email
        params[:email].presence || params.dig(:user, :email)
      end

      def login_password
        params[:password].presence || params.dig(:user, :password)
      end

      def portal
        params[:portal].to_s
      end

      def portal_allowed?(user)
        case portal
        when "store"
          user.has_role?(:customer)
        when "staff"
          user.has_role?(:admin) || user.has_role?(:cashier) || user.has_role?(:owner) || user.has_role?(:courier)
        else
          true
        end
      end

      def portal_error_message
        portal == "store" ? "Akun ini bukan pelanggan toko." : "Akun ini tidak memiliki akses staff."
      end
    end
  end
end
