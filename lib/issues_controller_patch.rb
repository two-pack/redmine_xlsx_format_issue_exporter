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
      if params[:format] != 'xlsx'
        return index_without_xlsx
      end

      retrieve_query
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      @limit = Setting.issues_export_limit.to_i
      if params[:columns] == 'all'
        @query.column_names = @query.available_inline_columns.map(&:name)
      end

      @issue_count = @query.issue_count
      @issue_pages = Redmine::Pagination::Paginator.new @issue_count, @limit, params['page']
      @offset ||= @issue_pages.offset
      @issues = query_issues
      @issue_count_by_group = @query.issue_count_by_group

      send_data(query_to_xlsx(@issues, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'issues.xlsx')
    end
  end
end

ActionDispatch::Reloader.to_prepare do
  unless IssuesController.included_modules.include?(IssuesControllerPatch)
    IssuesController.send(:include, IssuesControllerPatch)
  end
end
