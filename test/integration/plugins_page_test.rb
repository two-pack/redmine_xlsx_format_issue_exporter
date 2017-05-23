require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class PluginsPageTest < ActionDispatch::IntegrationTest
    fixtures :members, :users

    def setup
      login_with_admin

      visit '/admin/plugins'
      assert_not_nil page
    end

    def teardown
      logout
    end

    def test_that_the_page_has_the_plguin
      screenshot_and_save_page
      assert page.has_selector?('tr#plugin-redmine_xlsx_format_issue_exporter')
    end

    def test_that_the_page_has_valid_plguin_name
      page.has_css?('tr#plugin-redmine_xlsx_format_issue_exporter td.name span.name', text: 'Issues XLS export')
    end

  end
end