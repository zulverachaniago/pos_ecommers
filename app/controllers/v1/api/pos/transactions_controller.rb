# frozen_string_literal: true

module V1
  module Api
    module Pos
      class TransactionsController < BaseController
        before_action :set_transaction, only: :show

        def index
          authorize PosTransaction
          transactions = paginate_scope(
            PosTransaction.includes(:user, :customer, pos_transaction_items: { product_variant: :product })
                          .order(created_at: :desc)
          )
          render_collection(transactions, transactions.map { |transaction| json.pos_transaction(transaction) })
        end

        def show
          authorize @transaction
          render_success(json.pos_transaction(@transaction))
        end

        def create
          authorize PosTransaction
          transaction = PosTransaction.new(pos_transaction_params)
          transaction.user = current_user
          transaction.transaction_number = "POS-#{Time.current.strftime('%Y%m%d%H%M%S')}"
          transaction.payment_status = :paid
          transaction.customer ||= walk_in_customer

          if transaction.save
            transaction = PosTransaction.includes(:user, :customer, pos_transaction_items: { product_variant: :product }).find(transaction.id)
            render_success(json.pos_transaction(transaction), message: "Transaksi berhasil disimpan.", status: :created)
          else
            render_invalid(transaction)
          end
        end

        private

        def set_transaction
          @transaction = PosTransaction.includes(:user, :customer, pos_transaction_items: { product_variant: :product }).find(params[:id])
        end

        def walk_in_customer
          Customer.find_or_create_by!(name: "Pelanggan Umum") do |customer|
            customer.customer_type = "retail"
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
    end
  end
end
