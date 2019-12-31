module RedmineXlsxFormatIssueExporter
  module IssuesControllerPatch
    include XlsxExportHelper

    def add_params_from_settings(name)
      if params[name.to_sym] == "1"
        params[:c] << name unless params[:c].include?(name.to_sym)
      else
        params[:c].delete_if {|c| c == name} unless params[:c].nil?
      end
    end

    def index
      saved_column_names = session[:issue_query][:column_names] if session[:issue_query].present?
      saved_column_names ||= session[:query][:column_names] if session[:query].present?

      if params[:format] == 'xlsx'
        add_params_from_settings("description")
        add_params_from_settings("last_notes")
      end

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