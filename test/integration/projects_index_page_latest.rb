require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class ProjectsIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users

    def setup
      visit '/projects?display_type=list'
      assert_not_nil page
    end

    def teardown
      logout
    end

    def test_that_default_list_view_has_XLSX_link
      Setting.project_list_display_type = "list"
      visit '/projects'
      Setting.project_list_display_type = "board"
      assert_not_nil page

      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

  end
end