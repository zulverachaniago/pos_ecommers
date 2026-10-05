# frozen_string_literal: true

module V1
  module Api
    module Owner
      class SuppliersController < BaseController
        before_action :require_owner!

        def index
          suppliers = paginate_scope(Supplier.order(:name))
          render_collection(suppliers, suppliers.map { |supplier| json.supplier(supplier) })
        end
      end
    end
  end
end
