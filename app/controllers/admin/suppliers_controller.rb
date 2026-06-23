class Admin::SuppliersController < ApplicationController
  layout "admin"
  before_action :set_supplier, only: [:edit, :update, :destroy]

  def index
    authorize Supplier
    scope = Supplier.order(:name)
    @suppliers = paginate_scope(scope)
  end

  def new
    authorize Supplier
    @supplier = Supplier.new
  end

  def create
    authorize Supplier
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to admin_suppliers_path, notice: "Supplier berhasil ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @supplier
  end

  def update
    authorize @supplier
    if @supplier.update(supplier_params)
      redirect_to admin_suppliers_path, notice: "Supplier berhasil diupdate."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @supplier
    @supplier.destroy
    redirect_to admin_suppliers_path, notice: "Supplier berhasil dihapus."
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :contact_person, :phone, :address)
  end
end
