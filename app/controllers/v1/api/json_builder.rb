# frozen_string_literal: true

module V1
  module Api
    class JsonBuilder
      def initialize(controller)
        @controller = controller
      end

      def user(record)
        {
          id: record.id,
          email: record.email,
          roles: record.roles.map { |role| role(role) },
          customer: record.customer ? customer(record.customer) : nil,
          sign_in_count: record.sign_in_count,
          current_sign_in_at: record.current_sign_in_at,
          last_sign_in_at: record.last_sign_in_at,
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def role(record, user_count: nil)
        payload = {
          id: record.id,
          name: record.name,
          label: record.display_name,
          description: Role::DESCRIPTIONS[record.name],
          system: record.system?
        }
        payload[:users_count] = user_count unless user_count.nil?
        payload
      end

      def customer(record)
        {
          id: record.id,
          name: record.name,
          phone: record.phone,
          address: record.address,
          customer_type: record.customer_type,
          balance: money(record.balance),
          user_id: record.user_id,
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def category(record)
        {
          id: record.id,
          name: record.name,
          description: record.description
        }
      end

      def supplier(record)
        {
          id: record.id,
          name: record.name,
          contact_person: record.contact_person,
          phone: record.phone,
          address: record.address
        }
      end

      def product(record, stock_totals: nil)
        variants = record.product_variants.to_a
        summary = StockInventory.product_summary(variants, totals: stock_totals || StockInventory.totals_hash(variants.map(&:id)))

        {
          id: record.id,
          name: record.name,
          description: record.description,
          sku: record.sku,
          barcode: record.barcode,
          is_active: record.is_active,
          image_url: image_url(record),
          category: record.category ? category(record.category) : nil,
          supplier: record.association(:supplier).loaded? && record.supplier ? supplier(record.supplier) : (record.supplier_id && record.supplier ? supplier(record.supplier) : nil),
          variants: variants.map { |variant| variant(variant, stock_totals: stock_totals) },
          stock: {
            label: summary[:label],
            total: summary[:total],
            status: summary[:status],
            status_label: StockInventory.status_label(summary[:status])
          },
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def variant(record, stock_totals: nil)
        on_hand = StockInventory.on_hand(record, totals: stock_totals)
        status = StockInventory.status(on_hand, record.stock_minimum.to_i)

        {
          id: record.id,
          product_id: record.product_id,
          variant_name: record.variant_name,
          unit: record.unit,
          price_grosir: money(record.price_grosir),
          price_ecer: money(record.price_ecer),
          stock_minimum: record.stock_minimum,
          stock: on_hand,
          stock_status: status,
          stock_status_label: StockInventory.status_label(status)
        }
      end

      def cart_item(record, stock_totals: nil)
        variant_record = record.product_variant
        {
          id: record.id,
          quantity: record.quantity,
          subtotal: money(record.subtotal),
          variant: variant(variant_record, stock_totals: stock_totals),
          product: {
            id: variant_record.product.id,
            name: variant_record.product.name,
            sku: variant_record.product.sku,
            image_url: image_url(variant_record.product)
          }
        }
      end

      def wishlist_item(record, stock_totals: nil)
        {
          id: record.id,
          product: product(record.product, stock_totals: stock_totals),
          created_at: record.created_at
        }
      end

      def order(record)
        {
          id: record.id,
          order_number: record.order_number,
          order_date: record.order_date,
          status: record.status,
          order_status: record.order_status,
          order_status_label: record.order_status_label,
          payment_method: record.payment_method,
          payment_method_label: record.payment_method_label,
          total_amount: money(record.total_amount),
          notes: record.notes,
          customer: record.customer ? customer(record.customer) : nil,
          courier: record.courier ? { id: record.courier.id, email: record.courier.email } : nil,
          items: record.order_items.map { |item| order_item(item) },
          status_records: record.order_status_records.sort_by(&:created_at).map { |entry| status_record(entry) },
          next_statuses: next_statuses(record),
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def order_item(record)
        variant_record = record.product_variant
        {
          id: record.id,
          quantity: record.quantity,
          price_at_sale: money(record.price_at_sale),
          subtotal: money(record.subtotal),
          variant: {
            id: variant_record.id,
            variant_name: variant_record.variant_name,
            unit: variant_record.unit,
            product_id: variant_record.product_id,
            product_name: variant_record.product.name,
            sku: variant_record.product.sku
          }
        }
      end

      def status_record(record)
        {
          id: record.id,
          order_status: record.order_status,
          status_label: record.status_label,
          notes: record.notes,
          actor: record.actor_name,
          created_at: record.created_at
        }
      end

      def pos_transaction(record)
        {
          id: record.id,
          transaction_number: record.transaction_number,
          payment_method: record.payment_method,
          payment_status: record.payment_status,
          total_amount: money(record.total_amount),
          amount_paid: money(record.amount_paid),
          change_amount: money(record.change_amount),
          customer: record.customer ? customer(record.customer) : nil,
          cashier: record.user ? { id: record.user.id, email: record.user.email } : nil,
          items: record.pos_transaction_items.map { |item| pos_item(item) },
          created_at: record.created_at
        }
      end

      def pos_item(record)
        variant_record = record.product_variant
        {
          id: record.id,
          quantity: record.quantity,
          price_at_sale: money(record.price_at_sale),
          subtotal: money(record.subtotal),
          variant: {
            id: variant_record.id,
            variant_name: variant_record.variant_name,
            unit: variant_record.unit,
            product_id: variant_record.product_id,
            product_name: variant_record.product.name,
            sku: variant_record.product.sku
          }
        }
      end

      def stock_movement(record)
        {
          id: record.id,
          movement_type: record.movement_type,
          movement_type_label: record.movement_type_label,
          quantity: record.quantity,
          quantity_label: record.quantity_label,
          stock_before: record.stock_before,
          stock_after: record.stock_after,
          notes: record.notes,
          reference: record.reference_label,
          variant: {
            id: record.product_variant.id,
            variant_name: record.product_variant.variant_name,
            unit: record.product_variant.unit,
            product_id: record.product_variant.product_id,
            product_name: record.product_variant.product.name,
            sku: record.product_variant.product.sku
          },
          user: { id: record.user_id, email: record.user&.email },
          created_at: record.created_at
        }
      end

      def pos_catalog_variant(record, stock_totals: nil)
        price = record.price_ecer.to_d.positive? ? record.price_ecer : record.price_grosir
        on_hand = StockInventory.on_hand(record, totals: stock_totals)

        {
          id: record.id,
          product_id: record.product_id,
          label: "#{record.product.name} — #{record.variant_name}",
          sku: record.product.sku,
          barcode: record.product.barcode,
          price: money(price),
          price_grosir: money(record.price_grosir),
          price_ecer: money(record.price_ecer),
          stock: on_hand,
          unit: record.unit,
          image_url: image_url(record.product)
        }
      end

      private

      def money(value)
        return nil if value.nil?

        value.to_f
      end

      def image_url(record)
        return unless record.respond_to?(:image) && record.image.attached?

        @controller.rails_blob_url(record.image)
      end

      def next_statuses(order)
        current_step = Order.order_statuses[order.order_status]
        next_status = Order.order_statuses.key(current_step + 1)
        next_status ? [ next_status ] : []
      end
    end
  end
end
