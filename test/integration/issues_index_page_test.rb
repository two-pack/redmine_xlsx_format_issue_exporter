require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class IssuesIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :trackers, :issue_statuses, :issues, :roles,
             :member_roles, :enumerations, :users, :issue_categories,
             :queries, :projects_trackers, :issue_relations, :watchers,
             :journals, :journal_details, :attachments,
             :members, :enabled_modules, :workflows,
             :custom_values, :custom_fields, :custom_fields_projects, :custom_fields_trackers,
             :versions, :time_entries

    def setup
      Capybara.reset!
      visit '/projects/ecookbook/issues'
      assert_visit
    end

    def teardown
      logout
    end

    def test_not_permitted_index_page
      login_with_no_permitted_user
      visit '/projects/ecookbook/issues'

      short_wait_time do
        assert_raises(Capybara::ElementNotFound) {
          assert find("Issues", :visible => true)
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

    def test_that_export_with_selected_columns
      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_with_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_with_description
      click_link("XLSX")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_with_description_and_all_columns
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_all_projects
      visit '/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects/onlinestore/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_with_query
      page.select("is")
      page.select("Assigned")
      click_link("Apply")
      click_link("XLSX")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_all_projects_with_query
      visit '/issues'
      uncheck("Status")
      click_link("Apply")
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")
      find("div#xlsx-export-options").check("Description")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_export_private_issue_which_is_TrueClass
      login_with_admin
      visit '/projects/subproject1/issues'
      click_link("XLSX")
      find("div#xlsx-export-options").choose("All Columns")

      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects/subproject1/issues?utf8=%E2%9C%93&set_filter=1&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D'

      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

    def test_to_export_with_sort
      login_with_admin

      visit '/projects/subproject1/issues?sort=id'

      click_link("XLSX")
      find("div#xlsx-export-options").click_button("Export")

      assert stay_issues_index_page?
    end
  end
end

if (Redmine::VERSION::MAJOR >= 4) then
  require File.expand_path(File.dirname(__FILE__) + '/issues_index_page_latest')
elsif (Redmine::VERSION::MAJOR == 3) && (Redmine::VERSION::MINOR == 4) then
  require File.expand_path(File.dirname(__FILE__) + '/issues_index_page_34x')
else
  require File.expand_path(File.dirname(__FILE__) + '/issues_index_page_33x')
end
