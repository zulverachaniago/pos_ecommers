# frozen_string_literal: true

# Excel export (HTML table, dibuka di Excel/LibreOffice)
%i[xls xlsx].each do |symbol|
  Mime::Type.register "application/vnd.ms-excel", symbol
rescue StandardError
  # sudah terdaftar
end
