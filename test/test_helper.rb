require "simplecov"
SimpleCov.start do
  add_group "XLSX Exporter", "plugins/redmine_xlsx_format_issue_exporter"
end

require File.expand_path(File.dirname(__FILE__) + "/../../../test/test_helper")

require "capybara/rails"
require "capybara/poltergeist"

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  #Capybara.default_wait_time = 15
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist

  def login(user, password)
    visit "/"

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

end