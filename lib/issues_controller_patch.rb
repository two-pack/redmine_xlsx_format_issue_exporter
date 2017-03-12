require_dependency 'issues_controller'

module IssuesControllerPatch
  include XlsxExportHelper

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :index, :xlsx
    end
  end

  module InstanceMethods
    def query_issues
      options = {:order => sort_clause, :offset => @offset, :limit => @limit}
      if (Redmine::VERSION::MAJOR <= 3) && (Redmine::VERSION::MINOR <= 3) && (Redmine::VERSION::BRANCH != 'devel') then
        options.merge!({:include => [:assigned_to, :tracker, :priority, :category, :fixed_version]})
      end
      @query.issues(options)
    end

    def index_with_xlsx
      begin
        return index_without_xlsx
      rescue ActionController::UnknownFormat => e
        if params[:format] != 'xlsx'
          raise e
        end
      end

      send_data(query_to_xlsx(@issues, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'issues.xlsx')
    end
  end
end

ActionDispatch::Reloader.to_prepare do
  unless IssuesController.included_modules.include?(IssuesControllerPatch)
    IssuesController.send(:include, IssuesControllerPatch)
  end
end
