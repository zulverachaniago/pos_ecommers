class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy]
  layout "admin"

  def index
    authorize Product
    @q = Product.ransack(params[:q])
    scope = @q.result(distinct: true)
                .includes(:category, :product_variants)
                .with_attached_image
                .order(name: :asc)
    @products = paginate_scope(scope)
    variant_ids = @products.flat_map { |product| product.product_variants.map(&:id) }
    @stock_totals = StockInventory.totals_hash(variant_ids)
    @categories = Category.order(:name)
  end

  def new
    authorize Product
    @product = Product.new
    @product.product_variants.build  # Siapkan 1 variant kosong
  end

  def create
    authorize Product
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_products_path, notice: "Produk berhasil ditambahkan."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
    @product.product_variants.build if @product.product_variants.empty?
    @stock_totals = StockInventory.totals_hash(@product.product_variant_ids)
  end

  def update
    authorize @product
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Produk berhasil diupdate."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to admin_products_path, notice: "Produk berhasil dihapus."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :category_id, :supplier_id, :sku, :barcode, :is_active, :image,
      product_variants_attributes: [:id, :variant_name, :price_grosir, :price_ecer, 
                                   :stock_minimum, :unit, :_destroy]
    )
  end
end
