module ApplicationHelper
  include StockHelper

  def pagination_summary(collection)
    return "Tidak ada data" unless collection.respond_to?(:total_count)
    return "Tidak ada data" if collection.total_count.zero?

    from = collection.offset_value + 1
    to = collection.offset_value + collection.size
    "Menampilkan #{from}–#{to} dari #{collection.total_count} data"
  end

  def whatsapp_phone_number(phone)
    return if phone.blank?

    digits = phone.to_s.gsub(/\D/, "")
    digits = "62#{digits[1..]}" if digits.start_with?("0")
    digits
  end

  def whatsapp_url(phone, message: nil)
    number = whatsapp_phone_number(phone)
    return if number.blank?

    url = "https://wa.me/#{number}"
    url += "?text=#{ERB::Util.url_encode(message)}" if message.present?
    url
  end

  def order_whatsapp_message(order)
    payment = order.payment_method_label
    total = number_with_delimiter(order.total_amount.to_i)
    "Halo #{order.customer.name}, kami dari Oder Store terkait pesanan #{order.order_number}. Total Rp #{total} (#{payment}). Mohon konfirmasi untuk pengiriman. Terima kasih."
  end

  def order_qr_code(order, size: 140)
    payload = order.order_number

    if defined?(RQRCode)
      qr = RQRCode::QRCode.new(payload)
      module_size = [[size / qr.modules.count, 2].max, 8].min
      qr.as_svg(
        offset: 0,
        color: "000",
        shape_rendering: "crispEdges",
        module_size: module_size,
        standalone: true,
        use_path: true
      ).html_safe
    else
      image_tag(
        "https://quickchart.io/qr?text=#{ERB::Util.url_encode(payload)}&size=#{size}&margin=1",
        alt: "QR #{payload}",
        width: size,
        height: size,
        class: "delivery-slip-qr-img"
      )
    end
  end
end
