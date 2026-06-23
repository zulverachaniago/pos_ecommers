# # frozen_string_literal: true

# puts "=== Seeding Oder Store ==="

# # ==================== SUPPLIER ====================
# puts "Membuat supplier..."

# suppliers_data = [
#   { name: "CV. Maju Jaya Grosir", contact_person: "Budi Santoso", phone: "0812-3456-7890", address: "Pasar Induk Klapanunggal" },
#   { name: "UD. Berkah Abadi", contact_person: "Siti Rahayu", phone: "0857-1234-5678", address: "Cileungsi" },
#   { name: "PT. Sumber Rejeki", contact_person: "Ahmad Fauzi", phone: "0819-8765-4321", address: "Gunung Putri" }
# ]

# suppliers = suppliers_data.map do |data|
#   Supplier.find_or_create_by!(name: data[:name]) do |s|
#     s.contact_person = data[:contact_person]
#     s.phone = data[:phone]
#     s.address = data[:address]
#   end
# end

# # ==================== CATEGORY ====================
# # puts "Membuat kategori..."

# category_names = [
#   "Mie Instan & Snack", "Minuman", "Sabun & Deterjen", "Rokok & Korek",
#   "Beras & Sembako", "Minyak & Bumbu", "Obat & Vitamin", "Perlengkapan Rumah"
# ]

# categories = category_names.index_with do |name|
#   Category.find_or_create_by!(name: name)
# end

# # ==================== PRODUCTS (100 macam) ====================
# puts "Membuat 100 produk beserta variant..."

# # [nama, price_grosir, price_ecer, unit, variant_name]
# catalog = {
#   "Mie Instan & Snack" => [
#     ["Indomie Goreng", 2800, 3500, "pcs", "1 pcs"],
#     ["Indomie Kuah Ayam Bawang", 2800, 3500, "pcs", "1 pcs"],
#     ["Indomie Soto", 2800, 3500, "pcs", "1 pcs"],
#     ["Indomie Rendang", 2800, 3500, "pcs", "1 pcs"],
#     ["Indomie Kari Ayam", 2800, 3500, "pcs", "1 pcs"],
#     ["Mie Sedap Goreng", 2500, 3200, "pcs", "1 pcs"],
#     ["Mie Sedap Kuah", 2500, 3200, "pcs", "1 pcs"],
#     ["Supermi Goreng", 2400, 3000, "pcs", "1 pcs"],
#     ["Pop Mie Goreng", 3500, 4500, "cup", "1 cup"],
#     ["Chitato Sapi Panggang", 9500, 11000, "pack", "68g"],
#     ["Qtela Rasa Keju", 9000, 10500, "pack", "60g"],
#     ["Taro Net Keju", 8500, 10000, "pack", "55g"],
#     ["Biskuit Roma Kelapa", 7000, 8500, "pack", "300g"],
#     ["Wafer Tango Coklat", 5500, 7000, "pack", "130g"],
#     ["Slai O'lai Coklat", 6500, 8000, "pack", "168g"]
#   ],
#   "Minuman" => [
#     ["Le Minerale 600ml", 3500, 4500, "botol", "600ml"],
#     ["Aqua 600ml", 3000, 4000, "botol", "600ml"],
#     ["Pocari Sweat 350ml", 6500, 8000, "botol", "350ml"],
#     ["Teh Botol Sosro", 4500, 5500, "botol", "450ml"],
#     ["Frestea Teh Hijau", 5000, 6000, "botol", "500ml"],
#     ["Ultra Milk Coklat 250ml", 5500, 6500, "kotak", "250ml"],
#     ["Yakult", 6000, 7500, "pack", "5 botol"],
#     ["Kopi Kapal Api Special", 1500, 2000, "sachet", "1 sachet"],
#     ["Good Day Cappuccino", 1500, 2000, "sachet", "1 sachet"],
#     ["Nescafe Classic", 1500, 2000, "sachet", "1 sachet"],
#     ["Fruit Tea Apple", 1200, 1500, "sachet", "1 sachet"],
#     ["Marjan Melon 460ml", 18000, 21000, "botol", "460ml"],
#     ["Teh Kotak Sosro", 4500, 5500, "kotak", "250ml"],
#     ["Coca Cola 390ml", 5500, 7000, "botol", "390ml"],
#     ["Sprite 390ml", 5500, 7000, "botol", "390ml"]
#   ],
#   "Sabun & Deterjen" => [
#     ["Lifebuoy Batang", 4500, 5500, "pcs", "1 batang"],
#     ["Dove Beauty Bar", 6500, 8000, "pcs", "1 batang"],
#     ["Rinso Deterjen Cair", 25000, 29000, "botol", "800ml"],
#     ["Molto Pewangi", 12000, 14500, "botol", "900ml"],
#     ["So Klin Liquid", 18000, 21000, "botol", "800ml"],
#     ["Wipol Pembersih Lantai", 14000, 16500, "botol", "800ml"],
#     ["Sunlight Jeruk Nipis", 6500, 8000, "botol", "230ml"],
#     ["Pepsodent Herbal", 8500, 10000, "pcs", "1 tube"],
#     ["Sikat Gigi Formula", 3500, 4500, "pcs", "1 pcs"],
#     ["Sabun Cuci Piring Sunlight", 6500, 8000, "botol", "230ml"],
#     ["Downy Mystique", 16000, 18500, "botol", "680ml"],
#     ["Bayclin Pemutih", 11000, 13000, "botol", "600ml"]
#   ],
#   "Rokok & Korek" => [
#     ["Sampoerna Mild", 28500, 32000, "pack", "1 bungkus"],
#     ["Marlboro Filter Black", 32000, 36000, "pack", "1 bungkus"],
#     ["Djarum Super", 22000, 25000, "pack", "1 bungkus"],
#     ["Gudang Garam Filter", 24000, 27000, "pack", "1 bungkus"],
#     ["Surya 12", 23000, 26000, "pack", "1 bungkus"],
#     ["Korek Gas Tokai", 5000, 6500, "pcs", "1 pcs"],
#     ["Korek Api Kayu", 2000, 3000, "box", "1 box"],
#     ["Sampoerna Kretek", 20000, 23000, "pack", "1 bungkus"]
#   ],
#   "Beras & Sembako" => [
#     ["Beras Premium 5kg", 75000, 82000, "karung", "5 kg"],
#     ["Beras Medium 5kg", 65000, 72000, "karung", "5 kg"],
#     ["Gula Pasir 1kg", 14000, 16000, "pack", "1 kg"],
#     ["Gula Merah 500g", 8000, 9500, "pack", "500g"],
#     ["Tepung Terigu Segitiga 1kg", 11000, 13000, "pack", "1 kg"],
#     ["Minyak Goreng Filma 1L", 18000, 21000, "botol", "1 liter"],
#     ["Minyak Goreng Bimoli 1L", 17500, 20500, "botol", "1 liter"],
#     ["Mie Telur Cap Burung Dara", 9000, 11000, "pack", "200g"],
#     ["Mie Kuning Cap Ayam", 8500, 10000, "pack", "200g"],
#     ["Sagu Mutiara 500g", 6000, 7500, "pack", "500g"],
#     ["Bihun Jagung Rose Brand", 7000, 8500, "pack", "200g"],
#     ["Kacang Tanah Kupas 500g", 18000, 21000, "pack", "500g"]
#   ],
#   "Minyak & Bumbu" => [
#     ["Bumbu Racik Ayam Goreng", 2500, 3500, "pack", "1 sachet"],
#     ["Bumbu Racik Nasi Goreng", 2500, 3500, "pack", "1 sachet"],
#     ["Bumbu Racik Opor", 2500, 3500, "pack", "1 sachet"],
#     ["Kecap Manis Bango 520ml", 22000, 25000, "botol", "520ml"],
#     ["Kecap Manis ABC 525ml", 20000, 23000, "botol", "525ml"],
#     ["Saus Sambal ABC 335ml", 12000, 14000, "botol", "335ml"],
#     ["Saus Tomat Del Monte", 15000, 17500, "botol", "340g"],
#     ["Mecin Masako Ayam", 3500, 4500, "pack", "1 sachet"],
#     ["Royco Ayam", 1500, 2000, "sachet", "1 sachet"],
#     ["Garam Dolpin 500g", 5000, 6500, "pack", "500g"],
#     ["Merica Bubuk Desa", 8000, 9500, "botol", "50g"],
#     ["Cabai Bubuk Desa", 9000, 10500, "botol", "50g"],
#     ["Minyak Wijen Cap Halal", 16000, 18500, "botol", "150ml"],
#     ["Santan Kara 200ml", 5500, 6500, "kotak", "200ml"],
#     ["Terasi Udang ABC", 7000, 8500, "pack", "100g"]
#   ],
#   "Obat & Vitamin" => [
#     ["Paracetamol 500mg", 3000, 4000, "strip", "4 tablet"],
#     ["Promag Tablet", 6000, 7500, "strip", "4 tablet"],
#     ["Tolak Angin Cair", 4500, 5500, "sachet", "1 sachet"],
#     ["Antangin JRG", 4000, 5000, "sachet", "1 sachet"],
#     ["Konidin Batuk", 8000, 9500, "botol", "60ml"],
#     ["Betadine 15ml", 12000, 14000, "botol", "15ml"],
#     ["Hansaplast Kecil", 5000, 6500, "box", "10 pcs"],
#     ["Vitamin C IPI", 2500, 3500, "strip", "4 tablet"],
#     ["OBH Combi Batuk", 9000, 11000, "botol", "100ml"],
#     ["Plester Luka Hypafix", 8000, 9500, "roll", "1 roll"]
#   ],
#   "Perlengkapan Rumah" => [
#     ["Tissue Paseo 250 Sheet", 12000, 14000, "pack", "1 pack"],
#     ["Tissue Basah Mitu", 8500, 10000, "pack", "10 lembar"],
#     ["Kantong Plastik Kecil", 8000, 9500, "pack", "1 pack"],
#     ["Spons Cuci Piring", 3500, 4500, "pcs", "1 pcs"],
#     ["Serbet Lap Dapur", 5000, 6500, "pack", "3 pcs"],
#     ["Pembalut Wanita Charm", 6500, 8000, "pack", "1 pack"],
#     ["Popok Bayi Mami Poko", 85000, 95000, "pack", "1 pack"],
#     ["Pemutih Pakaian Vanish", 18000, 21000, "botol", "800ml"],
#     ["Korek Api Gas Isi Ulang", 15000, 18000, "botol", "250g"],
#     ["Lilin Hias", 5000, 6500, "pack", "6 pcs"],
#     ["Korek Kompor Gas", 3500, 4500, "pcs", "1 pcs"],
#     ["Pengki Plastik", 8000, 9500, "pcs", "1 pcs"],
#     ["Sapu Lidi", 12000, 14000, "pcs", "1 pcs"]
#   ]
# }

# sku_counter = 0

# catalog.each do |category_name, items|
#   category = categories[category_name]
#   items.each do |name, price_grosir, price_ecer, unit, variant_name|
#     sku_counter += 1
#     sku = format("PRD%03d", sku_counter)
#     supplier = suppliers[sku_counter % suppliers.size]

#     product = Product.find_or_initialize_by(sku: sku)
#     product.assign_attributes(
#       name: name,
#       description: "#{name} — produk #{category_name.downcase}",
#       category: category,
#       supplier: supplier,
#       is_active: true
#     )
#     product.save!

#     variant = product.product_variants.find_or_initialize_by(variant_name: variant_name)
#     variant.assign_attributes(
#       unit: unit,
#       price_grosir: price_grosir,
#       price_ecer: price_ecer,
#       stock_minimum: [10, 20, 50].sample
#     )
#     variant.save!

#     # Variant dus/karton untuk sebagian produk murah (mie, kopi, bumbu)
#     if price_grosir <= 5000 && sku_counter.even?
#       dus_variant = product.product_variants.find_or_initialize_by(variant_name: "1 dus (40 pcs)")
#       dus_variant.assign_attributes(
#         unit: "dus",
#         price_grosir: price_grosir * 38,
#         price_ecer: 0,
#         stock_minimum: 5
#       )
#       dus_variant.save!
#     end
#   end
# end

# puts "   → Produk: #{Product.count}, Variant: #{ProductVariant.count}"

# # ==================== CUSTOMERS (50) ====================
# puts "Membuat 50 customer..."

# warung_names = [
#   "Warung Pak Budi", "Warung Mbak Siti", "Toko Bu Ani", "Warung Pak Joko",
#   "Toko Sejahtera", "Warung Bu Dewi", "Toko Barokah", "Warung Pak Udin",
#   "Toko Rezeki", "Warung Mbak Yuni", "Toko Berkah Jaya", "Warung Pak Agus",
#   "Toko Bu Fitri", "Warung Pak Rudi", "Toko Makmur", "Warung Bu Rina",
#   "Toko Sumber Rejeki", "Warung Pak Eko", "Toko Bu Lina", "Warung Pak Hendra"
# ]

# retail_first_names = %w[
#   Ani Budi Citra Dewi Eko Fitri Gunawan Hadi Ibu Joko Kurnia Lina
#   Maya Nia Oki Putri Qori Rina Siti Tono Umi Vera Wati Yani Zul
# ]

# areas = [
#   "Klapanunggal", "Cileungsi", "Gunung Putri", "Jonggol", "Cibubur",
#   "Bojong Ngeder", "Cikeas", "Citeureup", "Karadenan", "Nambo"
# ]

# 50.times do |i|
#   n = i + 1
#   phone = format("0812%08d", n)

#   if i < 20
#     name = warung_names[i % warung_names.size]
#     name = "#{name} #{n}" if Customer.exists?(name: name)
#     customer_type = "business"
#   else
#     first = retail_first_names[i % retail_first_names.size]
#     name = "Ibu #{first} #{n}"
#     customer_type = "retail"
#   end

#   Customer.find_or_create_by!(phone: phone) do |c|
#     c.name = name
#     c.address = "Jl. Raya #{areas[i % areas.size]} No.#{n}"
#     c.customer_type = customer_type
#     c.balance = customer_type == "business" ? rand(0..500_000) : 0
#   end
# end

# Customer.find_or_create_by!(name: "Pelanggan Umum") do |c|
#   c.customer_type = "retail"
# end

# puts "   → Customer: #{Customer.count}"

# puts "✅ Seeding selesai!"
# puts "   - Supplier: #{Supplier.count}"
# puts "   - Kategori: #{Category.count}"
# puts "   - Produk: #{Product.count}"
# puts "   - Product Variant: #{ProductVariant.count}"
# puts "   - Customer: #{Customer.count}"

# ==================== STOCK AWAL (dummy) ====================
# Jalankan setelah data produk/variant dari seed di atas sudah ada di database.
# Idempotent: variant yang sudah punya stok awal seed akan dilewati.

# puts "=== Seeding stok awal ==="

# admin_user = User.with_role(:admin).first || User.first

# if admin_user.nil?
#   puts "⚠️  Lewati stok: belum ada user. Buat user admin dulu."
# elsif ProductVariant.none?
#   puts "⚠️  Lewati stok: belum ada product variant. Uncomment & jalankan seed produk terlebih dahulu."
# else
#   STOCK_SEED_NOTES = "Stok awal (db:seed)"

#   seed_stock_quantity = lambda do |variant|
#     product = variant.product
#     sku_num = product.sku.to_s[/\d+/].to_i
#     sku_num = variant.id if sku_num.zero?

#     return 10 + (sku_num % 15) if variant.variant_name.to_s.include?("dus")

#     case product.category&.name
#     when "Mie Instan & Snack"
#       variant.unit.in?(%w[pack cup]) ? 80 + (sku_num % 70) : 180 + (sku_num % 220)
#     when "Minuman"
#       variant.unit == "sachet" ? 250 + (sku_num % 150) : 90 + (sku_num % 80)
#     when "Sabun & Deterjen"
#       60 + (sku_num % 90)
#     when "Rokok & Korek"
#       variant.unit == "box" ? 40 + (sku_num % 30) : 100 + (sku_num % 50)
#     when "Beras & Sembako"
#       variant.unit == "karung" ? 30 + (sku_num % 20) : 55 + (sku_num % 45)
#     when "Minyak & Bumbu"
#       variant.unit == "sachet" ? 300 + (sku_num % 200) : 70 + (sku_num % 60)
#     when "Obat & Vitamin"
#       45 + (sku_num % 55)
#     when "Perlengkapan Rumah"
#       variant.unit == "pcs" && product.name.to_s.include?("Popok") ? 15 + (sku_num % 10) : 50 + (sku_num % 80)
#     else
#       60 + (sku_num % 100)
#     end
#   end

#   variants = ProductVariant.includes(product: :category).order("products.sku")
#   seeded = 0
#   skipped = 0

#   variants.find_each do |variant|
#     if StockMovement.exists?(product_variant: variant, movement_type: :stock_in, notes: STOCK_SEED_NOTES)
#       skipped += 1
#       next
#     end

#     StockMovementRecorder.record_manual!(
#       variant: variant,
#       quantity: seed_stock_quantity.call(variant),
#       movement_type: :stock_in,
#       user: admin_user,
#       notes: STOCK_SEED_NOTES
#     )
#     seeded += 1
#   end

#   puts "   → Stok awal: #{seeded} variant dicatat, #{skipped} dilewati (sudah ada)"
#   puts "   → Total pergerakan stok: #{StockMovement.count}"
#   puts "✅ Seeding stok selesai!"
# end

