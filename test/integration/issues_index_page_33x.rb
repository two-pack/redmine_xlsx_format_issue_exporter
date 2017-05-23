require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class IssuesIndexPage33xTest < ActionDispatch::IntegrationTest
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

    def test_that_dialog_has_not_last_notes
      click_link("XLSX")

      assert_raises(Capybara::ElementNotFound) {
        find("input#last_notes")
      }
    end

    def test_that_dialog_has_files_option
      click_link("XLSX")

      assert find("input#files")
      assert_equal false, has_checked_field?("Files")
    end

    def test_to_export_with_files
      click_link("XLSX")
      find("div#xlsx-export-options").check("Files")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

    def test_to_export_with_all_aditional_options
      click_link("XLSX")
      find("div#xlsx-export-options").check("Description")
      find("div#xlsx-export-options").check("Files")

      find("div#xlsx-export-options").click_button("Export")

      assert_equal 200, page.status_code
    end

  end
end