class Product < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :category, optional: true

  has_one_attached :image
  
  has_many :product_variants, dependent: :destroy
  accepts_nested_attributes_for :product_variants, allow_destroy: true, reject_if: :all_blank
  has_many :stock_movements
  has_many :order_items
  has_many :cart_items
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_products, through: :wishlist_items, source: :product

  validate :acceptable_image

  def self.ransackable_attributes(_auth_object = nil)
    %w[name sku barcode description is_active category_id supplier_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category supplier product_variants]
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
      errors.add(:image, "harus berformat JPG, PNG, WebP, atau GIF")
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, "maksimal 5 MB")
    end
  end
end