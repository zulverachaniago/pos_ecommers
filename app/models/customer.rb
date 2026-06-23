class Customer < ApplicationRecord
  belongs_to :user, optional: true

  has_many :orders
  has_many :pos_transactions
  has_one :cart, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_products, through: :wishlist_items, source: :product

  enum :customer_type, { business: 0, retail: 1 }

  validates :name, presence: true
  validates :phone, uniqueness: true, allow_blank: true
  validates :user_id, uniqueness: true, allow_nil: true

  attribute :address, :string
end
