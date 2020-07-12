require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class ProjectsIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users

    def setup
      visit '/projects?display_type=list'
      assert_visit
    end

    def teardown
      logout
    end

    def test_that_default_list_view_has_XLSX_link
      Setting.project_list_display_type = "list"
      visit '/projects'
      Setting.project_list_display_type = "board"
      assert_visit

      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

  end
end