require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class UsersReportPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users, :email_addresses, :members,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :time_entries

    ActiveRecord::FixtureSet.create_fixtures(
        File.dirname(__FILE__) + '/../fixtures/', [:roles, :member_roles])

    def setup
      Capybara.reset!

      page.driver.headers = { "Accept-Language" => "en-US" }
    end

    def teardown
      logout
    end

    def visit_users_page_with_admin
      login_with_admin
      visit '/users'
      assert_not_nil page
    end

    def test_not_permitted_users_page
      login_with_no_permitted_user
      visit '/users'

      short_wait_time do
        assert_raises(Capybara::ElementNotFound) {
          assert find("Users", :visible => true)
        }
      end
    end

    def test_that_dialog_is_not_shown_when_the_link_is_clicked
      visit_users_page_with_admin

      click_link("XLSX")

      assert_raises(Capybara::ElementNotFound) {
        assert find("div#xlsx-export-options", :visible => true)
      }
    end

    def test_to_export
      visit_users_page_with_admin

      click_link("XLSX")

      assert_equal 200, page.status_code
    end

    def test_invalid_format_request
      login_with_admin

      visit '/users.test'

      assert_equal 406, page.status_code
    end

  end
end if Redmine::VERSION::BRANCH == 'devel'