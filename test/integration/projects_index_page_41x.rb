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

    def test_not_permitted_index_page
      login_with_no_permitted_user
      visit '/projects?display_type=list'

      short_wait_time do
        assert_raises(Capybara::ElementNotFound) {
          assert find("Projects", :visible => true)
        }
      end
    end

    def test_that_the_page_has_XLSX_link
      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

    def test_that_dialog_is_shown_when_the_link_is_clicked
      click_link("XLSX")

      assert find("div#xlsx-export-options", :visible => true)
    end

    def test_that_dialog_is_closed_when_cancel_is_clicked
      click_link("XLSX")
      find("div#xlsx-export-options").click_link("Cancel")

      assert find("div#xlsx-export-options", :visible => false)
    end

    def test_that_the_page_of_board_has_not_XLSX_link
      visit '/projects?display=board'
      assert_visit

      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

    def test_that_default_board_view_has_not_XLSX_link
      visit '/projects'
      assert_visit

      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

    def test_that_export_with_selected_columns
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_with_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_all_projects
      visit '/projects?display_type=list'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects?display_type=list'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_with_query
      page.select("is")
      page.select("closed")
      click_link("Apply")
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_all_projects_with_query
      visit '/projects?display_type=list'
      uncheck("Status")
      click_link("Apply")
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects?utf8=✓&set_filter=1&f%5B%5D=status&op%5Bstatus%5D=%3D&display_type=list'
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

    def test_to_export_with_sort
      login_with_admin
      visit '/projects?display_type=list&sort=name'

      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert stay_projects_index_page?
    end

  end
end