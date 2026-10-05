# frozen_string_literal: true

module V1
  module Api
    module Admin
      class RolesController < BaseController
        before_action :set_role, only: [:show, :update, :destroy]

        def index
          authorize Role
          roles = paginate_scope(Role.global.ordered)
          counts = User.joins(:roles).group("roles.id").count
          render_collection(roles, roles.map { |role| json.role(role, user_count: counts[role.id].to_i) })
        end

        def show
          authorize @role
          users = paginate_scope(@role.users.includes(:roles, :customer).order(:email))
          render_success(
            json.role(@role, user_count: @role.users.count).merge(users: users.map { |user| json.user(user) }),
            meta: pagination_meta(users)
          )
        end

        def create
          authorize Role
          role = Role.new(role_params)
          if role.save
            render_success(json.role(role, user_count: 0), message: "Role berhasil ditambahkan.", status: :created)
          else
            render_invalid(role)
          end
        end

        def update
          authorize @role
          if @role.update(role_params)
            render_success(json.role(@role, user_count: @role.users.count), message: "Role berhasil diupdate.")
          else
            render_invalid(@role)
          end
        end

        def destroy
          authorize @role
          if @role.system?
            render_error("Role sistem (#{@role.display_name}) tidak dapat dihapus.")
          elsif @role.users.any?
            render_error("Role masih digunakan oleh #{@role.users.count} pengguna.")
          else
            @role.destroy!
            render_success(message: "Role berhasil dihapus.")
          end
        end

        private

        def set_role
          @role = Role.find(params[:id])
        end

        def role_params
          params.require(:role).permit(:name)
        end
      end
    end
  end
end
