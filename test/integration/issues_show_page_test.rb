require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module RedmineXlsxFormatIssueExporter
  class IssuesShowTest < ActionDispatch::IntegrationTest
    fixtures :projects, :trackers, :issue_statuses, :issues,
             :enumerations, :users, :issue_categories, :queries,
             :projects_trackers, :issue_relations, :watchers,
             :roles, :journals, :journal_details, :attachments,
             :member_roles, :members, :enabled_modules, :workflows,
             :custom_values, :custom_fields, :custom_fields_projects, :custom_fields_trackers,
             :versions, :time_entries

    def setup

    end

    def teardown

    end

    def test_that_not_affect_show_page
      visit '/issues/1'

      assert stay_issues_index_page?
    end

  end
end
