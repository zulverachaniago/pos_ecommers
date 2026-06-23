class Admin::UsersController < ApplicationController
  layout "admin"

  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :load_roles, only: [:new, :create, :edit, :update]

  def index
    authorize User
    scope = User.includes(:roles).order(:email)
    @users = paginate_scope(scope)
  end

  def show
    authorize @user
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    authorize User
    @user = User.new(user_params)

    if @user.save
      sync_user_role(@user, role_param)
      redirect_to admin_users_path, notice: "Pengguna berhasil ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      sync_user_role(@user, role_param) if role_param.present?
      redirect_to admin_user_path(@user), notice: "Data pengguna berhasil diupdate."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "Pengguna berhasil dihapus."
  end

  private

  def set_user
    @user = User.includes(:roles).find(params[:id])
  end

  def load_roles
    @roles = %w[admin cashier owner courier]
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
