# frozen_string_literal: true

module ExportRespondable
  extend ActiveSupport::Concern

  private

  def respond_index_with_export(scope:, ivar:, filename:, headers:, &row_builder)
    respond_to do |format|
      format.html do
        instance_variable_set("@#{ivar}", paginate_scope(scope))
      end
      format.csv do
        rows = scope.map { |record| row_builder.call(record) }
        send_export_csv(filename, headers, rows)
      end
      format.xls do
        rows = scope.map { |record| row_builder.call(record) }
        send_export_xls(filename, headers, rows)
      end
    end
  end

  def send_export_csv(filename, headers, rows)
    send_data ExportService.to_csv(headers, rows),
              filename: "#{filename}.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  def send_export_xls(filename, headers, rows)
    send_data ExportService.to_xls(headers, rows),
              filename: "#{filename}.xls",
              type: "application/vnd.ms-excel",
              disposition: "attachment"
  end
end
