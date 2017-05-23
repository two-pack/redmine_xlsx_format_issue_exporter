require_dependency 'timelog_controller'

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

      @entries = time_entry_scope.
          preload(:issue => [:project, :tracker, :status, :assigned_to, :priority]).
          preload(:project, :user).
          to_a
      send_data(query_to_xlsx(@entries, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'timelog.xlsx')
    end

    def report
      begin
        return super
      rescue ActionController::UnknownFormat => e
        if params[:format] != 'xlsx'
          raise e
        end
      end

      send_data(report_to_xlsx(@report), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'timelog.xlsx')
    end
  end
end

ActionDispatch::Reloader.to_prepare do
  unless TimelogController.included_modules.include?(RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
    TimelogController.send(:prepend, RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
  end
end
