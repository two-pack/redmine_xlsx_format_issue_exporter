Redmine::Plugin.register :redmine_xlsx_format_issue_exporter do
  name 'Redmine XLSX format issue exporter'
  author 'Tatsuya Saito'
  description 'This is Redmine plugin which exports issue list to XLSX format file.'
  version '0.1.0'
  url 'https://github.com/two-pack/redmine_xlsx_format_issue_exporter'
  author_url 'mailto:twopackas@gmail.com'
  requires_redmine :version_or_higher => '2.3'
end

require 'issues_page_hooks'