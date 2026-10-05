# frozen_string_literal: true

module V1
  module Api
    module Admin
      class UsersController < BaseController
        before_action :set_user, only: [:show, :update, :destroy]

        def index
          authorize User
          users = paginate_scope(User.includes(:roles, :customer).order(:email))
          render_collection(users, users.map { |user| json.user(user) })
        end

        def show
          authorize @user
          render_success(json.user(@user))
        end

        def create
          authorize User
          user = User.new(user_params)
          if user.save
            sync_user_role(user, role_param)
            render_success(json.user(user.reload), message: "Pengguna berhasil ditambahkan.", status: :created)
          else
            render_invalid(user)
          end
        end

        def update
          authorize @user
          if @user.update(user_params)
            sync_user_role(@user, role_param) if role_param.present?
            render_success(json.user(@user.reload), message: "Data pengguna berhasil diupdate.")
          else
            render_invalid(@user)
          end
        end

        def destroy
          authorize @user
          @user.destroy!
          render_success(message: "Pengguna berhasil dihapus.")
        rescue ActiveRecord::RecordNotDestroyed
          render_error("Pengguna tidak dapat dihapus.")
        end

        private

        def set_user
          @user = User.includes(:roles, :customer).find(params[:id])
        end

        def user_params
          permitted = params.require(:user).permit(:email, :password, :password_confirmation)
          if permitted[:password].blank?
            permitted.delete(:password)
            permitted.delete(:password_confirmation)
          end
          permitted
        end

        def role_param
          params.dig(:user, :role)
        end

        def sync_user_role(user, role_name)
          return if role_name.blank?

          user.roles.pluck(:name).each { |name| user.remove_role(name) }
          user.add_role(role_name)
        end
      end
    end
  end
end
