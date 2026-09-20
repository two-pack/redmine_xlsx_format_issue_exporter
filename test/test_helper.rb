require 'simplecov'
SimpleCov.coverage_dir('coverage/redmine_xlsx_format_issue_exporter_test')
filter_method = SimpleCov.respond_to?(:skip) ? :skip : :add_filter
group_method = SimpleCov.respond_to?(:group) ? :group : :add_group
SimpleCov.start 'rails' do
  send(filter_method) do |source_file|
    # report this plugin only.
    !source_file.filename.include?('plugins/redmine_xlsx_format_issue_exporter') || !source_file.filename.end_with?('.rb')
  end

  send(group_method, 'XLSX Exporter', 'plugins/redmine_xlsx_format_issue_exporter')
end

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

require 'capybara/rails'
require 'selenium-webdriver'

Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_option('w3c', false)
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--window-size=1280,800')
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: options
  )
end

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[--headless --disable-site-isolation-trials])
  options.add_preference('credentials_enable_service', false)
  options.add_preference('profile.password_manager_enabled', false)
  options.add_preference('profile.password_manager_leak_detection', false)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.current_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 10

module RedmineXlsxFormatIssueExporter
  class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL

    def login(user, password)
      Capybara.reset_sessions!
      visit '/login'
      fill_in 'username', with: user
      fill_in 'password', with: password
      find('input#login-submit').click
      assert find('a.logout', visible: :all)
    end

    def logout
      visit '/'
      if has_css?('a.logout', wait: 0)
        find('a.logout').click
        assert find('a.login', visible: :all)
      end
    end

    def before_teardown
      save_failure_artifacts if failures.any?
      super
    end

    def save_failure_artifacts
      dir = Rails.root.join('tmp', 'capybara')
      FileUtils.mkdir_p(dir)
      base = dir.join("#{self.class.name}-#{name}".gsub(/\W+/, '_'))
      page.save_screenshot("#{base}.png")
      File.write("#{base}.html", page.html)
      File.write("#{base}.txt", [
        diagnostic('url') { page.current_url },
        diagnostic('wait time') { Capybara.default_max_wait_time },
        diagnostic('dialog visible') { page.evaluate_script("jQuery('#xlsx-export-options').is(':visible')") },
        diagnostic('browser') { page.driver.browser.capabilities.browser_version },
        diagnostic('chromedriver') { page.driver.browser.capabilities['chrome']['chromedriverVersion'] },
        diagnostic('console') { page.driver.browser.logs.get(:browser).map(&:message).join("\n") }
      ].join("\n"))
    rescue StandardError => e
      warn "Failed to save the failure artifacts: #{e.class}: #{e.message}"
    end

    def diagnostic(label)
      "#{label}: #{yield}"
    rescue StandardError => e
      "#{label}: (#{e.class}: #{e.message})"
    end

    def login_with_admin
      login 'admin', 'admin'
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
    ensure
      Capybara.default_max_wait_time = default_wait_time
    end

    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end

    def assert_visit
      assert has_selector?('div#content')
    end

    def stay_page?(selector)
      assert has_selector?(selector, visible: true)
      short_wait_time do
        assert has_no_selector?('div#xlsx-export-options', visible: true)
      end
    end

    def stay_issues_index_page?
      stay_page?('body.controller-issues')
    end

    def stay_timelog_index_page?
      stay_page?('body.controller-timelog')
    end

    def stay_timelog_report_page?
      stay_page?('body.controller-timelog.action-report')
    end

    def stay_users_index_page?
      stay_page?('body.controller-users')
    end

    def stay_projects_index_page?
      stay_page?('body.controller-projects')
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
