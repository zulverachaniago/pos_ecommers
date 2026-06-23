# frozen_string_literal: true

class Owner::CustomersController < Owner::BaseController
  def index
    authorize Customer, policy_class: Owner::CustomerPolicy

    scope = Customer.order(name: :asc)

    respond_index_with_export(
      scope: scope,
      ivar: :customers,
      filename: "data-pelanggan-#{Date.current}",
      headers: ["Nama", "Tipe", "Telepon", "Alamat", "Saldo (Rp)"]
    ) do |c|
      [c.name, c.customer_type, c.phone, c.address, c.balance.to_i]
    end
  end
end
