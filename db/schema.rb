# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_09_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_carts_on_customer_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.text "address"
    t.decimal "balance"
    t.datetime "created_at", null: false
    t.string "customer_type"
    t.string "name"
    t.string "phone"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_customers_on_user_id", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price_at_sale"
    t.bigint "product_variant_id", null: false
    t.integer "quantity"
    t.decimal "subtotal"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "order_status_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "order_id", null: false
    t.integer "order_status", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["order_id", "created_at"], name: "index_order_status_records_on_order_id_and_created_at"
    t.index ["order_id"], name: "index_order_status_records_on_order_id"
    t.index ["user_id"], name: "index_order_status_records_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "courier_id"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "notes"
    t.datetime "order_date"
    t.string "order_number"
    t.integer "order_status", default: 1, null: false
    t.integer "payment_method", default: 1, null: false
    t.integer "status"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
    t.index ["courier_id"], name: "index_orders_on_courier_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["order_status"], name: "index_orders_on_order_status"
    t.index ["payment_method"], name: "index_orders_on_payment_method"
  end

  create_table "pos_transaction_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "pos_transaction_id", null: false
    t.decimal "price_at_sale"
    t.bigint "product_variant_id", null: false
    t.integer "quantity"
    t.decimal "subtotal"
    t.datetime "updated_at", null: false
    t.index ["pos_transaction_id"], name: "index_pos_transaction_items_on_pos_transaction_id"
    t.index ["product_variant_id"], name: "index_pos_transaction_items_on_product_variant_id"
  end

  create_table "pos_transactions", force: :cascade do |t|
    t.decimal "amount_paid", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "payment_method"
    t.integer "payment_status"
    t.decimal "total_amount"
    t.string "transaction_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_id"], name: "index_pos_transactions_on_customer_id"
    t.index ["user_id"], name: "index_pos_transactions_on_user_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "price_ecer"
    t.decimal "price_grosir"
    t.bigint "product_id", null: false
    t.integer "stock_minimum"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.string "variant_name"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "barcode"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active"
    t.string "name"
    t.string "sku"
    t.bigint "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "movement_type"
    t.text "notes"
    t.bigint "product_variant_id", null: false
    t.integer "quantity"
    t.bigint "referenceable_id"
    t.string "referenceable_type"
    t.integer "stock_after"
    t.integer "stock_before"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_stock_movements_on_created_at"
    t.index ["movement_type"], name: "index_stock_movements_on_movement_type"
    t.index ["product_variant_id"], name: "index_stock_movements_on_product_variant_id"
    t.index ["referenceable_type", "referenceable_id"], name: "index_stock_movements_on_referenceable"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.text "address"
    t.string "contact_person"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "product_id"], name: "index_wishlist_items_on_customer_id_and_product_id", unique: true
    t.index ["customer_id"], name: "index_wishlist_items_on_customer_id"
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "customers"
  add_foreign_key "customers", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_status_records", "orders"
  add_foreign_key "order_status_records", "users"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "users", column: "courier_id"
  add_foreign_key "pos_transaction_items", "pos_transactions"
  add_foreign_key "pos_transaction_items", "product_variants"
  add_foreign_key "pos_transactions", "customers"
  add_foreign_key "pos_transactions", "users"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "suppliers"
  add_foreign_key "stock_movements", "product_variants"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "wishlist_items", "customers"
  add_foreign_key "wishlist_items", "products"
end
