Redmine::Plugin.register :redmine_xlsx_format_issue_exporter do
  name 'Redmine XLSX format issue exporter'
  author 'Tatsuya Saito'
  description 'This is Redmine plugin which exports XLSX format file.'
  version '0.1.5'
  url 'https://github.com/two-pack/redmine_xlsx_format_issue_exporter'
  author_url 'mailto:twopackas@gmail.com'
  requires_redmine :version_or_higher => '2.3'
end

require_dependency 'queries_helper'
require_dependency 'redmine_xlsx_format_issue_exporter/xlsx_export_helper'
require_dependency 'redmine_xlsx_format_issue_exporter/xlsx_report_helper'
require_dependency 'redmine_xlsx_format_issue_exporter/xlsx_users_helper'

require_dependency 'redmine_xlsx_format_issue_exporter/view_layouts_base_body_bottom_hook'

Rails.configuration.to_prepare do
  require_dependency 'issues_controller'
  require_dependency 'timelog_controller'
  require_dependency 'users_controller'

  unless IssuesController.included_modules.include? RedmineXlsxFormatIssueExporter::IssuesControllerPatch
    IssuesController.send(:prepend, RedmineXlsxFormatIssueExporter::IssuesControllerPatch)
  end

  unless TimelogController.included_modules.include?(RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
    TimelogController.send(:prepend, RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
  end

  unless UsersController.included_modules.include?(RedmineXlsxFormatIssueExporter::UsersControllerPatch)
    UsersController.send(:prepend, RedmineXlsxFormatIssueExporter::UsersControllerPatch)
  end
end