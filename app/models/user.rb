class User < ApplicationRecord
  rolify
  has_one :customer, dependent: :destroy
  has_many :order_status_records, dependent: :nullify
  has_many :courier_orders, class_name: "Order", foreign_key: :courier_id, dependent: :nullify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  def create_customer_profile
    return customer if customer.present?

    create_customer(
      name: email.to_s.split("@").first.capitalize,
      customer_type: :retail,
      balance: 0
    )
  end
end
