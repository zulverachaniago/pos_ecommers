# frozen_string_literal: true

module V1
  module Api
    class RegistrationsController < BaseController
      skip_before_action :authenticate_api_user!, only: :create

      def create
        user = User.new(registration_params)
        unless user.save
          render_invalid(user)
          return
        end

        user.add_role(:customer) unless user.has_role?(:customer)
        customer = user.create_customer_profile
        customer.update(profile_params) if profile_params.present?

        render_success(
          { token: issue_token(user), token_type: "Bearer", expires_in: TOKEN_TTL.to_i, user: json.user(user.reload) },
          message: "Registrasi berhasil.",
          status: :created
        )
      end

      private

      def registration_params
        source = params[:user].presence || params
        source.permit(:email, :password, :password_confirmation)
      end

      def profile_params
        source = params[:customer].presence || params[:user].presence || params
        source.permit(:name, :phone, :address, :customer_type).to_h.reject { |_, value| value.blank? }
      end
    end
  end
end
