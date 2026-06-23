class Pos::TransactionsController < Pos::BaseController
  before_action :set_transaction, only: [:show]

  def index
    authorize PosTransaction
    scope = PosTransaction.includes(:user, :customer, :pos_transaction_items)
                          .order(created_at: :desc)
    @transactions = paginate_scope(scope)
  end

  def new
    authorize PosTransaction
    @transaction = PosTransaction.new
    load_variants
    load_customers_json
  end

  def create
    authorize PosTransaction
    @transaction = PosTransaction.new(pos_transaction_params)
    @transaction.user = current_user
    @transaction.transaction_number = "POS-#{Time.current.strftime('%Y%m%d%H%M%S')}"
    @transaction.payment_status = :paid
    assign_customer!

    if @transaction.save
      redirect_to pos_transaction_path(@transaction), notice: "Transaksi berhasil disimpan."
    else
      load_variants
      load_customers_json
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @transaction
  end

  private

  def set_transaction
    @transaction = PosTransaction.includes(pos_transaction_items: { product_variant: :product }).find(params[:id])
  end

  def load_variants
    variants = ProductVariant.joins(:product)
                             .where(products: { is_active: true })
                             .includes(:product)
                             .order("products.name")

    @variants_json = variants.map do |v|
      price = v.price_ecer.to_d.positive? ? v.price_ecer : v.price_grosir
      stock = StockInventory.on_hand(v)
      {
        id: v.id,
        label: "#{v.product.name} — #{v.variant_name}",
        sku: v.product.sku,
        price: price.to_f,
        stock: stock,
        unit: v.unit
      }
    end.to_json
  end

  def load_customers_json
    @customers_json = Customer.where.not(name: "Pelanggan Umum")
                              .order(:name)
                              .map do |c|
      {
        id: c.id,
        name: c.name,
        phone: c.phone,
        address: c.address,
        type: c.customer_type
      }
    end.to_json
  end

  def assign_customer!
    return if @transaction.customer_id.present?

    @transaction.customer = walk_in_customer
  end

  def walk_in_customer
    Customer.find_or_create_by!(name: "Pelanggan Umum") do |c|
      c.customer_type = "retail"
    end
  end

  def pos_transaction_params
    params.require(:pos_transaction).permit(
      :customer_id,
      :payment_method,
      :amount_paid,
      pos_transaction_items_attributes: [:product_variant_id, :quantity, :price_at_sale, :_destroy]
    )
  end
end
