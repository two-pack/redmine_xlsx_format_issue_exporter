require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IssuesPageTest < ActionDispatch::IntegrationTest
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

  def test_that_dialog_has_files_option
    click_link("XLSX")

    assert find("input#files")
    assert_equal false, has_checked_field?("Files")
  end

  def test_that_warning_is_NOT_shown_when_issues_count_is_less_setting
    click_link("XLSX")

    assert has_no_selector?("p.icon-warning")
  end

  def test_that_warning_is_shown_when_issues_count_is_over_setting
    limit = Setting.issues_export_limit
    Setting.issues_export_limit = 1
    Setting.issues_export_limit.to_i  # updates setting immediately

    visit '/projects/ecookbook/issues'
    click_link("XLSX")

    assert has_selector?("p.icon-warning")

    Setting.issues_export_limit = limit
    Setting.issues_export_limit.to_i    # updates setting immediately
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

  def test_to_export_with_files
    click_link("XLSX")
    find("div#xlsx-export-options").check("Files")

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

    logout
  end
end