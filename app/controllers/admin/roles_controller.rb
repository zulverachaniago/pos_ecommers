class Admin::RolesController < ApplicationController
  layout "admin"

  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    authorize Role
    scope = Role.global.ordered
    @roles = paginate_scope(scope)
    @user_counts = User.joins(:roles).group("roles.id").count
  end

  def show
    authorize @role
    scope = @role.users.order(:email)
    @users = paginate_scope(scope)
  end

  def new
    authorize Role
    @role = Role.new
  end

  def create
    authorize Role
    @role = Role.new(role_params)

    if @role.save
      redirect_to admin_role_path(@role), notice: "Role berhasil ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @role
  end

  def update
    authorize @role

    if @role.update(role_params)
      redirect_to admin_role_path(@role), notice: "Role berhasil diupdate."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @role

    if @role.system?
      redirect_to admin_roles_path, alert: "Role sistem (#{@role.display_name}) tidak dapat dihapus."
    elsif @role.users.any?
      redirect_to admin_roles_path, alert: "Role masih digunakan oleh #{@role.users.count} pengguna."
    else
      @role.destroy
      redirect_to admin_roles_path, notice: "Role berhasil dihapus."
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
