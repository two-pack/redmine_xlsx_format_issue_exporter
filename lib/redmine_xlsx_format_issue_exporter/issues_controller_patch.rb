require_dependency 'issues_controller'

module RedmineXlsxFormatIssueExporter
  module IssuesControllerPatch
    include XlsxExportHelper

    def index
      begin
        return super
      rescue ActionController::UnknownFormat => e
        if params[:format] != 'xlsx'
          raise e
        end
      end

      if @issues.nil?
        @issues = @query.issues(:limit => Setting.issues_export_limit.to_i)
      end
      send_data(query_to_xlsx(@issues, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'issues.xlsx')
    end
  end
end

ActionDispatch::Reloader.to_prepare do
  unless IssuesController.included_modules.include?(RedmineXlsxFormatIssueExporter::IssuesControllerPatch)
    IssuesController.send(:prepend, RedmineXlsxFormatIssueExporter::IssuesControllerPatch)
  end
end
