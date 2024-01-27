Redmine::Plugin.register :redmine_xlsx_format_issue_exporter do
  name 'Redmine XLSX format issue exporter'
  author 'Tatsuya Saito'
  description 'This is Redmine plugin which exports XLSX format file.'
  version '0.2.1'
  url 'https://github.com/two-pack/redmine_xlsx_format_issue_exporter'
  author_url 'mailto:twopackas@gmail.com'
  requires_redmine :version_or_higher => '4.2'
end

require_dependency 'queries_helper'
require_dependency 'query'
require_dependency 'issues_controller'
require_dependency 'timelog_controller'
require_dependency 'users_controller'
require_dependency 'projects_controller'
Dir[File.dirname(__FILE__) + '/lib/redmine_xlsx_format_issue_exporter/*.rb'].sort.each {|file|  require file }

def prepend_xlsx_format_issue_exporter_patches
  unless IssuesController.included_modules.include? RedmineXlsxFormatIssueExporter::IssuesControllerPatch
    IssuesController.send(:prepend, RedmineXlsxFormatIssueExporter::IssuesControllerPatch)
  end

  unless TimelogController.included_modules.include?(RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
    TimelogController.send(:prepend, RedmineXlsxFormatIssueExporter::TimelogControllerPatch)
  end

  unless UsersController.included_modules.include?(RedmineXlsxFormatIssueExporter::UsersControllerPatch)
    UsersController.send(:prepend, RedmineXlsxFormatIssueExporter::UsersControllerPatch)
  end

  unless ProjectsController.included_modules.include?(RedmineXlsxFormatIssueExporter::ProjectsControllerPatch)
    ProjectsController.send(:prepend, RedmineXlsxFormatIssueExporter::ProjectsControllerPatch)
  end
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  prepend_xlsx_format_issue_exporter_patches
else
  Rails.configuration.to_prepare do
    prepend_xlsx_format_issue_exporter_patches
  end
end
