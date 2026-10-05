# frozen_string_literal: true

module V1
  module Api
    module Owner
      class CustomersController < BaseController
        before_action :require_owner!

        def index
          customers = paginate_scope(Customer.order(name: :asc))
          render_collection(customers, customers.map { |customer| json.customer(customer) })
        end
      end
    end
  end
end
