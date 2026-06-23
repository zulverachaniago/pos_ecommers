class Admin::CustomersController < ApplicationController
  layout "admin"
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    authorize Customer
    scope = Customer.order(name: :asc)
    @customers = paginate_scope(scope)
  end

  def new
    authorize Customer
    @customer = Customer.new
  end

  def show
    authorize @customer
  end

  def edit
    authorize @customer
  end

  def create
    authorize Customer
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to admin_customers_path, notice: "Pelanggan berhasil ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    authorize @customer
    if @customer.update(customer_params)
      redirect_to admin_customers_path, notice: "Data pelanggan berhasil diupdate."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @customer
    @customer.destroy
    redirect_to admin_customers_path, notice: "Pelanggan berhasil dihapus."
  end

  private

  def set_customer
    @customer = Customer.includes(:user).find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :address, :customer_type, :balance)
  end
end