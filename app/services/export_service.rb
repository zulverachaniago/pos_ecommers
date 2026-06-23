# frozen_string_literal: true

require "csv"

class ExportService
  class << self
    def to_csv(headers, rows)
      CSV.generate(headers: true, encoding: "UTF-8") do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end
    end

    # Excel-compatible spreadsheet tanpa gem tambahan
    def to_xls(headers, rows)
      <<~HTML
        <html xmlns:o="urn:schemas-microsoft-com:office:office"
              xmlns:x="urn:schemas-microsoft-com:office:excel">
        <head><meta charset="UTF-8"></head>
        <body>
        <table border="1">
          <thead><tr>#{header_cells(headers)}</tr></thead>
          <tbody>#{body_rows(rows)}</tbody>
        </table>
        </body></html>
      HTML
    end

    private

    def header_cells(headers)
      headers.map { |h| "<th>#{escape(h)}</th>" }.join
    end

    def body_rows(rows)
      rows.map { |row| "<tr>#{row.map { |cell| "<td>#{escape(cell)}</td>" }.join}</tr>" }.join
    end

    def escape(value)
      value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end
  end
end
