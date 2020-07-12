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

    def test_that_the_page_has_not_XLSX_link
      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

  end
end