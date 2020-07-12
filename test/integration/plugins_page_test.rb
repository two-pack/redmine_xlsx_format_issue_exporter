require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class PluginsPageTest < ActionDispatch::IntegrationTest
    fixtures :members, :users

    def setup
      login_with_admin

      visit '/admin/plugins'
      assert_visit
    end

    def teardown
      logout
    end

    def test_that_the_page_has_the_plguin
      assert page.has_selector?('tr#plugin-redmine_xlsx_format_issue_exporter')
    end

    def test_that_the_page_has_valid_plguin_name
      assert page.has_css?('tr#plugin-redmine_xlsx_format_issue_exporter td.name span.name', text: 'Redmine XLSX format issue exporter')
    end

  end
end