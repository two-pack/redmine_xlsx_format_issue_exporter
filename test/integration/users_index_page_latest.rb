require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class UsersIndexPageTest < ActionDispatch::IntegrationTest
    fixtures :projects, :users, :email_addresses, :members, :roles, :member_roles

    def setup
      Capybara.reset!
    end

    def teardown
      logout
    end

    def visit_users_page_with_admin
      login_with_admin
      visit '/users'
      assert_visit
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

    if (Redmine::VERSION::MAJOR < 5) || ((Redmine::VERSION::MAJOR == 5) && (Redmine::VERSION::MINOR == 0))
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
  
        assert stay_users_index_page?
      end
    else
      def test_that_dialog_is_shown_when_the_link_is_clicked
        visit_users_page_with_admin

        click_link("XLSX")
  
        assert find("div#xlsx-export-options", :visible => true)
      end

      def test_to_export
        visit_users_page_with_admin
  
        click_link("XLSX")
        find("div#xlsx-export-options").click_button("Export")
  
        assert stay_users_index_page?
      end
    end

    def test_invalid_format_request
      login_with_admin

      visit '/users.test'

      assert page.has_css?("body > header > h1", :text => "ActionController::UnknownFormat in UsersController#index")
    end
  end
end
