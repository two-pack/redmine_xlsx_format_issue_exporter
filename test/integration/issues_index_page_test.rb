require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class IssuesIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :trackers, :issue_statuses, :issues,
             :enumerations, :users, :issue_categories, :queries,
             :projects_trackers, :issue_relations, :watchers,
             :roles, :journals, :journal_details, :attachments,
             :member_roles, :members, :enabled_modules, :workflows,
             :custom_values, :custom_fields, :custom_fields_projects, :custom_fields_trackers,
             :versions, :time_entries

    def setup
      page.driver.headers = { "Accept-Language" => "en-US" }

      visit '/projects/ecookbook/issues'
      assert_not_nil page
    end

    def teardown

    end

    def test_that_the_page_has_XLSX_link
      screenshot_and_save_page
      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

    def test_that_dialog_is_shown_when_the_link_is_clicked
      click_link("XLSX")

      assert find("div#xlsx-export-options", :visible => true)
    end

    def test_that_dialog_is_closed_when_cancel_is_clicked
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Cancel")

      assert find("div#xlsx-export-options", :visible => false)
    end

    def test_that_export_with_selected_columns
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_description
      click_link("XLSX")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_description_and_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_all_projects
      visit '/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects/onlinestore/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code

      logout
    end

    def test_to_export_with_query
      page.select("is")
      page.select("Assigned")
      click_link("Apply")
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_all_projects_with_query
      visit '/issues'
      uncheck("Status")
      click_link("Apply")
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_private_issue_which_is_TrueClass
      login_with_admin
      visit '/projects/subproject1/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code

      logout
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects/subproject1/issues?utf8=%E2%9C%93&set_filter=1&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D'
      assert_equal 200, page.status_code

      assert has_no_selector?("p.other-formats span a.xlsx")
      assert has_no_link?("XLSX")

      logout
    end

    def test_to_export_with_sort
      login_with_admin

      visit '/projects/subproject1/issues?sort=id'
      assert_equal 200, page.status_code

      find(:xpath, "//a[@href='/projects/subproject1/issues.xlsx?sort=id']").click
      assert_equal 200, page.status_code

      logout
    end
  end
end

if ((Redmine::VERSION::MAJOR == 3) && (Redmine::VERSION::MINOR >= 4)) or
   (Redmine::VERSION::MAJOR >= 4) then
  require File.expand_path(File.dirname(__FILE__) + '/issues_index_page_latest')
else
  require File.expand_path(File.dirname(__FILE__) + '/issues_index_page_33x')
end
