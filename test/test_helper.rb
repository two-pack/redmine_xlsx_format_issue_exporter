require "simplecov"
SimpleCov.coverage_dir('coverage/redmine_xlsx_format_issue_exporter_test')
SimpleCov.start "rails" do
  add_filter do |source_file|
    # report this plugin only.
    !source_file.filename.include?('plugins/redmine_xlsx_format_issue_exporter') || !source_file.filename.end_with?('.rb')
  end

  add_group "XLSX Exporter", "plugins/redmine_xlsx_format_issue_exporter"
end

require File.expand_path(File.dirname(__FILE__) + "/../../../test/test_helper")

require "capybara/rails"
require "capybara/poltergeist"
require "capybara-screenshot"

module RedmineXlsxFormatIssueExporter
  class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL

    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara.default_max_wait_time = 10

    def login(user, password)
      visit "/login"

      find("a.login").click
      fill_in "username", with: user
      fill_in "password", with: password
      find("input[name=login]").click
      assert page.find("a.logout")
    end

    def logout
      visit "/"
      if has_css?("a.logout")
        find("a.logout").click
        assert find("a.login")
      end
    end

    def login_with_admin
      login "admin", "admin"
    end

    def login_with_user
      login 'jsmith', 'jsmith'
    end

    def login_with_no_permitted_user
      login 'dlopper', 'foo'
    end

    def short_wait_time
      default_wait_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = 1
      yield
      Capybara.default_max_wait_time = default_wait_time
    end

    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end

    def select_and_wait(page, value, options = {})
      page.select(value, options)
      wait_for_ajax
    end
  end

  def make_action_controller_permitted_parameters(op, v)
    ActionController::Parameters.permit_all_parameters = true
    op_param = ActionController::Parameters.new(op)
    v_param = ActionController::Parameters.new(v)
    ActionController::Parameters.permit_all_parameters = false
    return op_param, v_param
  end
end

if ((Rails::VERSION::MAJOR < 5)) or
   ((Rails::VERSION::MAJOR == 5) and (Rails::VERSION::MINOR < 1))
  require File.expand_path(File.dirname(__FILE__) + '/rails4/action_controller/test_case')
end
