require_dependency 'issues_controller'

module IssuesControllerPatch
  include XlsxExportHelper

  def query_issues
    options = {:order => sort_clause, :offset => @offset, :limit => @limit}
    if (Redmine::VERSION::MAJOR <= 3) && (Redmine::VERSION::MINOR <= 3) && (Redmine::VERSION::BRANCH != 'devel') then
      options.merge!({:include => [:assigned_to, :tracker, :priority, :category, :fixed_version]})
    end
    @query.issues(options)
  end

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

ActionDispatch::Reloader.to_prepare do
  unless IssuesController.included_modules.include?(IssuesControllerPatch)
    IssuesController.send(:prepend, IssuesControllerPatch)
  end
end
