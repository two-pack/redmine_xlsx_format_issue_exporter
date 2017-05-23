require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class TimelogReportPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :time_entries

    def setup
      page.driver.headers = { "Accept-Language" => "en-US" }

      visit '/projects/ecookbook/time_entries/report'
      assert_not_nil page
    end

    def teardown

    end

    def test_that_the_page_has_XLSX_link_after_select
      page.select("Project")
      wait_for_ajax

      assert has_selector?("p.other-formats span a.xlsx")
      assert has_link?("XLSX")
    end

    def test_that_the_page_has_XLSX_link_before_select
      assert has_no_selector?("p.other-formats span a.xlsx")
      assert has_no_link?("XLSX")
    end

    def test_that_dialog_is_not_shown_when_the_link_is_clicked
      page.select("Project")
      wait_for_ajax

      click_link("XLSX")

      assert_raises(Capybara::ElementNotFound) {
        assert find("div#xlsx-export-options", :visible => true)
      }
    end

    def test_to_export_all_projects
      visit '/time_entries/report'
      page.find("#query_form_content").select("Project")
      page.find("#criterias").select("Project")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_to_export_small_project
      login_with_user
      visit '/projects/ecookbook/time_entries/report'
      page.select("Project")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code

      logout
    end

    def test_to_export_with_filter
      page.find("#add_filter_select").select("User")
      page.find("#values_user_id_1").select("John Smith")
      click_link("Apply")
      page.select("Status")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_to_set_status_filter_without_value
      login_with_admin
      visit '/projects/subproject1/time_entries/report?utf8=%E2%9C%93&set_filter=1&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D'
      assert_equal 200, page.status_code

      assert has_no_selector?("p.other-formats span a.xlsx")
      assert has_no_link?("XLSX")

      logout
    end

    def test_to_export_with_Project_Yearly
      page.find("#columns").select("Year")
      page.find("#criterias").select("Project")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_Project_and_Status_Monthly
      page.find("#columns").select("Month")
      page.find("#criterias").select("Project")
      page.find("#criterias").select("Status")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_Project_and_Status_and_more_Weekly
      page.find("#columns").select("Week")
      page.find("#criterias").select("Project")
      page.find("#criterias").select("Status")
      page.find("#criterias").select("Version")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_Project_and_Status_and_more_Daily
      page.find("#columns").select("Days")
      page.find("#criterias").select("Project")
      page.find("#criterias").select("Status")
      page.find("#criterias").select("Category")
      wait_for_ajax

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

  end
end