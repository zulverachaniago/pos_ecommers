class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  SYSTEM_NAMES = %w[admin cashier owner customer courier].freeze

  LABELS = {
    "admin" => "Admin",
    "cashier" => "Kasir",
    "owner" => "Owner",
    "customer" => "Customer",
    "courier" => "Kurir"
  }.freeze

  DESCRIPTIONS = {
    "admin" => "Akses penuh panel admin, kelola master data dan pengguna.",
    "cashier" => "Akses mode kasir untuk transaksi POS.",
    "owner" => "Akses panel owner, laporan penjualan dan stok.",
    "customer" => "Akses toko online untuk belanja.",
    "courier" => "Akses mode kurir untuk pengiriman pesanan online."
  }.freeze

  validates :name, presence: true,
                   uniqueness: { scope: %i[resource_type resource_id], case_sensitive: false },
                   format: { with: /\A[a-z0-9_]+\z/, message: "hanya huruf kecil, angka, dan underscore" }
  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  before_validation :normalize_name

  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :ordered, -> { order(:name) }

  def global?
    resource_type.blank? && resource_id.blank?
  end

  def system?
    global? && SYSTEM_NAMES.include?(name)
  end

  def display_name
    LABELS.fetch(name, name.titleize)
  end

  scopify

  private

  def normalize_name
    self.name = name.to_s.downcase.strip
  end
end
