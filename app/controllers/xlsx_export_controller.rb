class XlsxExportController < ApplicationController

  include QueriesHelper
  include SortHelper
  include IssuesHelper
  include XlsxExportHelper

  def index
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?

    retrieve_query
    params[:sort]=session['issues_index_sort'] if params[:sort].nil? && !session['issues_index_sort'].nil?
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    @limit = Setting.issues_export_limit.to_i
    if params[:columns] == 'all'
      @query.column_names = @query.available_inline_columns.map(&:name)
    end

    @issue_pages = Paginator.new @query.issue_count, @limit, params['page']
    @offset ||= @issue_pages.offset
    @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                            :order => sort_clause,
                            :offset => @offset,
                            :limit => @limit)

    send_data(query_to_xlsx(@issues, @query, params), :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;', :filename => 'issues.xlsx')
  end

end