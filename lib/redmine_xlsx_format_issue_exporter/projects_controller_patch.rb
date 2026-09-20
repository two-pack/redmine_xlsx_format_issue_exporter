# frozen_string_literal: true

module RedmineXlsxFormatIssueExporter
  # Adds the XLSX format to ProjectsController#index.
  module ProjectsControllerPatch
    include XlsxExportHelper

    def index
      begin
        return super
      rescue ActionController::UnknownFormat => e
        raise e if params[:format] != 'xlsx'
      end

      @entries = project_scope.to_a
      send_data(query_to_xlsx(@entries, @query, params),
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'projects.xlsx')
    end
  end
end
