require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class TimelogReportPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users, :email_addresses, :members, :roles, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :time_entries

    def setup
      Capybara.reset!

      visit '/projects/ecookbook/time_entries/report'
      assert_visit
    end

    def teardown
      logout
    end

    # Select criteria from drop-down.
    # This method waits selected node is invisible.
    def select_criteria_and_wait(value, options = {})
      10.times {
        select_and_wait(page, value, options)
        break if page.has_no_selector?('select#criterias option', :text => value)
      }
      assert page.has_no_selector?('select#criterias option', :text => value)
    end

    def test_not_permitted_report_page
      login_with_no_permitted_user
      visit '/projects/ecookbook/time_entries/report'

      short_wait_time do
        assert_raises(Capybara::ElementNotFound) {
          assert find("Spent time", :visible => true)
        }
      end
    end

    def test_that_the_page_has_XLSX_link_after_select
      select_criteria_and_wait("Project", :from => "criterias")

      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

    def test_that_the_page_has_XLSX_link_before_select
      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

    def test_that_dialog_is_not_shown_when_the_link_is_clicked
      select_criteria_and_wait("Project", :from => "criterias")

      click_link("XLSX")

      assert_raises(Capybara::ElementNotFound) {
        assert find("div#xlsx-export-options", :visible => true)
      }
    end

    def test_to_export_all_projects
      visit '/time_entries/report'
      select_criteria_and_wait("Project", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects/ecookbook/time_entries/report'
      select_criteria_and_wait("Project", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_export_with_filter
      select_and_wait(page, "User", :from => "add_filter_select")
      select_and_wait(page, "John Smith", :from => "values_user_id_1")
      click_link("Apply")
      select_criteria_and_wait("Status", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects/subproject1/time_entries/report?utf8=%E2%9C%93&set_filter=1&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D'

      short_wait_time do
        assert has_no_selector?("p.other-formats span a.xlsx")
        assert has_no_link?("XLSX")
      end
    end

    def test_to_export_with_Project_Yearly
      select_and_wait(page, "Year", :from => "columns")
      select_criteria_and_wait("Project", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_export_with_Project_and_Status_Monthly
      select_and_wait(page, "Month", :from => "columns")
      select_criteria_and_wait("Project", :from => "criterias")
      select_criteria_and_wait("Status", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_export_with_Project_and_Status_and_more_Weekly
      select_and_wait(page, "Week", :from => "columns")
      select_criteria_and_wait("Project", :from => "criterias")
      select_criteria_and_wait("Status", :from => "criterias")
      select_criteria_and_wait("Version", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

    def test_to_export_with_Project_and_Status_and_more_Daily
      select_and_wait(page, "Days", :from => "columns")
      select_criteria_and_wait("Project", :from => "criterias")
      select_criteria_and_wait("Status", :from => "criterias")
      select_criteria_and_wait("Category", :from => "criterias")

      click_link("XLSX")

      assert stay_timelog_report_page?
    end

  end
end