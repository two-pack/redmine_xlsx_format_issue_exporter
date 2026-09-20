# frozen_string_literal: true

module RedmineXlsxFormatIssueExporter
  module UsersControllerPatch
    include XlsxExportHelper
    include XlsxUsersHelper

    def index
      begin
        return super
      rescue ActionController::UnknownFormat => e
        raise e if params[:format] != 'xlsx'
      end

      scope = User.logged.status(@status).preload(:email_address)
      scope = scope.like(params[:name]) if params[:name].present?
      scope = scope.in_group(params[:group_id]) if params[:group_id].present?

      data = if (Redmine::VERSION::MAJOR == 5) && (Redmine::VERSION::MINOR == 0)
               users_to_xlsx(scope.order(sort_clause))
             else
               query_to_xlsx(@query.results_scope.to_a, @query, params)
             end
      send_data(data, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                      filename: 'users.xlsx')
    end
  end
end
