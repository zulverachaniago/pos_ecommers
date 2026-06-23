class Store::ProductsController < Store::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @categories = Category.order(:name)

    @products = Product.where(is_active: true)
                       .includes(:category, :product_variants)
                       .with_attached_image

    # Search
    if params[:search].present?
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", 
                                  "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter Kategori
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.order(name: :asc)
    @products = paginate_scope(@products)
    @stock_totals = StockInventory.totals_hash
  end

  def show
    @product = Product.with_attached_image.includes(:product_variants, :category).find(params[:id])
    @stock_totals = StockInventory.totals_hash(@product.product_variant_ids)
  end
end