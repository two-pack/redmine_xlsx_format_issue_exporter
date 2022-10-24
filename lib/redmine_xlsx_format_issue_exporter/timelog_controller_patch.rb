module RedmineXlsxFormatIssueExporter
  module TimelogControllerPatch
    include XlsxExportHelper
    include XlsxReportHelper

    def index
      begin
        return super
      rescue ActionController::UnknownFormat => e
        if params[:format] != 'xlsx'
          raise e
        end
      end

      @entries = time_entry_scope.to_a
      send_data(query_to_xlsx(@entries, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :filename => 'timelog.xlsx')
    end

    def report
      begin
        return super
      rescue ActionController::UnknownFormat => e
        if params[:format] != 'xlsx'
          raise e
        end
      end

      send_data(report_to_xlsx(@report), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :filename => 'timelog.xlsx')
    end
  end
end
