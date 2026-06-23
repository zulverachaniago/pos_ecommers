# frozen_string_literal: true

class Owner::SuppliersController < Owner::BaseController
  def index
    authorize Supplier, policy_class: Owner::SupplierPolicy

    scope = Supplier.includes(:products).order(:name)

    respond_index_with_export(
      scope: scope,
      ivar: :suppliers,
      filename: "data-supplier-#{Date.current}",
      headers: ["Nama", "Kontak", "Telepon", "Alamat", "Jumlah Produk"]
    ) do |s|
      [s.name, s.contact_person, s.phone, s.address, s.products.size]
    end
  end
end
