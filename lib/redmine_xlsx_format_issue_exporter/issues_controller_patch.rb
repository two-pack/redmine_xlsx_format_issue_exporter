module RedmineXlsxFormatIssueExporter
  module IssuesControllerPatch
    include XlsxExportHelper

    def index
      saved_column_names = session[:issue_query][:column_names] if session[:issue_query].present?
      saved_column_names ||= session[:query][:column_names] if session[:query].present?

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
      send_data(query_to_xlsx(@issues, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :filename => 'issues.xlsx')

      session[:issue_query][:column_names] = saved_column_names if session[:issue_query].present?
      session[:query][:column_names] = saved_column_names if session[:query].present?
    end
  end
end