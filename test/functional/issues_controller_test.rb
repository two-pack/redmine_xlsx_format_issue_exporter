require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IssuesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets

  include Redmine::I18n
  include RedmineXlsxFormatIssueExporter

  def column_names
    if session[:issue_query].present?
      session[:issue_query][:column_names]
    elsif session[:query].present?
      session[:query][:column_names]
    else
      nil
    end
  end

  def setup
    User.current = nil
  end

  def test_index_should_not_warn_when_not_exceeding_export_limit
    with_settings :issues_export_limit => 200 do
      get :index
      assert_select '#xlsx-export-options p.icon-warning', 0
    end
  end

  def test_index_should_warn_when_exceeding_export_limit
    with_settings :issues_export_limit => 2 do
      get :index
      assert_select '#xlsx-export-options p.icon-warning', :text => %r{limit: 2}
    end
  end

  def test_index_should_include_query_params_as_hidden_fields_in_xlsx_export_form
    if Redmine::VERSION::MAJOR < 3 or Redmine::VERSION::MINOR < 2
      assert "Ignore this test on old Redmine version,", true
      return
    end

    get :index, :params => {:project_id => 1,
                            :set_filter => "1",
                            :tracker_id => "2",
                            :sort => 'status',
                            :c => ["status", "priority"]}

    assert_select '#xlsx-export-form[action=?]', '/projects/ecookbook/issues.xlsx'
    assert_select '#xlsx-export-form[method=?]', 'get'

    assert_select '#xlsx-export-form' do
      assert_select 'input[name=?][value=?]', 'set_filter', '1'

      assert_select 'input[name=?][value=?]', 'f[]', 'tracker_id'
      assert_select 'input[name=?][value=?]', 'op[tracker_id]', '='
      assert_select 'input[name=?][value=?]', 'v[tracker_id][]', '2'

      assert_select 'input[name=?][value=?]', 'c[]', 'status'
      assert_select 'input[name=?][value=?]', 'c[]', 'priority'

      assert_select 'input[name=?][value=?]', 'sort', 'status'
    end
  end

  def test_index_xlsx
    get :index, :params => {:format => 'xlsx'}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_with_project
    get :index, :params => {:project_id => 1, :format => 'xlsx'}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_with_group_by
    get :index, :params => {:project_id => 1, :format => 'xlsx', :group_by => 'tracker'}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_with_description
    Issue.generate!(:description => 'test_index_xlsx_with_description')

    with_settings :default_language => 'en' do
      get :index, :params => {:format => 'xlsx', :xlsx => {:description => '1'}}
      assert_response :success
    end

    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', response.content_type
  end

  def test_index_xlsx_with_spent_time_column
    issue = Issue.create!(:project_id => 1, :tracker_id => 1, :subject => 'test_index_xlsx_with_spent_time_column', :author_id => 2)
    TimeEntry.create!(:project => issue.project, :issue => issue, :hours => 7.33, :user => User.find(2), :spent_on => Date.today)

    get :index, :params => {:format => 'xlsx', :set_filter => '1', :c => %w(subject spent_hours)}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_with_all_columns
    get :index, :params => {:format => 'xlsx', :xlsx => {:columns => 'all'}}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_with_multi_column_field
    CustomField.find(1).update_attribute :multiple, true
    issue = Issue.find(1)
    issue.custom_field_values = {1 => ['MySQL', 'Oracle']}
    issue.save!

    get :index, :params => {:format => 'xlsx', :xlsx => {:columns => 'all'}}
    assert_response :success
  end

  def test_index_xlsx_should_format_float_custom_fields_with_xlsx_decimal_separator
    field = IssueCustomField.create!(:name => 'Float', :is_for_all => true, :tracker_ids => [1], :field_format => 'float')
    issue = Issue.generate!(:project_id => 1, :tracker_id => 1, :custom_field_values => {field.id => '185.6'})

    with_settings :default_language => 'fr' do
      get :index, :params => {:format => 'xlsx', :xlsx => {:columns => 'all'}}
      assert_response :success
    end

    with_settings :default_language => 'en' do
      get :index, :params => {:format => 'xlsx', :xlsx => {:columns => 'all'}}
      assert_response :success
    end
  end

  def test_index_xlsx_should_fill_parent_column_with_parent_id
    Issue.delete_all
    parent = Issue.generate!
    child = Issue.generate!(:parent_issue_id => parent.id)

    with_settings :default_language => 'en' do
      get :index, :params => {:format => 'xlsx', :c => %w(parent)}
    end
  end

  def test_index_xlsx_big_5
    with_settings :default_language => "zh-TW" do
      str_utf8  = "\xe4\xb8\x80\xe6\x9c\x88".force_encoding('UTF-8')
      str_big5  = "\xa4@\xa4\xeb".force_encoding('Big5')
      issue = Issue.generate!(:subject => str_utf8)
      op, v = make_action_controller_permitted_parameters({'subject' => '='}, {'subject' => [str_utf8]})

      get :index, :params => {:project_id => 1,
                              :f => ['subject'],
                              :op => op,
                              :v => v,
                              :format => 'xlsx'}
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
    end
  end

  def test_index_xlsx_cannot_convert_should_be_replaced_big_5
    with_settings :default_language => "zh-TW" do
      str_utf8  = "\xe4\xbb\xa5\xe5\x86\x85".force_encoding('UTF-8')
      issue = Issue.generate!(:subject => str_utf8)
      op, v = make_action_controller_permitted_parameters({'subject' => '='}, {'subject' => [str_utf8]})

      get :index, :params => {:project_id => 1,
                              :f => ['subject'],
                              :op => op,
                              :v => v,
                              :c => ['status', 'subject'],
                              :format => 'xlsx',
                              :set_filter => 1}
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
    end
  end

  def test_index_xlsx_tw
    with_settings :default_language => "zh-TW" do
      str1  = "test_index_xlsx_tw"
      issue = Issue.generate!(:subject => str1, :estimated_hours => '1234.5')
      op, v = make_action_controller_permitted_parameters({'subject' => '='}, {'subject' => [str1]})

      get :index, :params => {:project_id => 1,
                              :f => ['subject'],
                              :op => op,
                              :v => v,
                              :c => ['estimated_hours', 'subject'],
                              :format => 'xlsx',
                              :set_filter => 1}
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
    end
  end

  def test_index_xlsx_fr
    with_settings :default_language => "fr" do
      str1  = "test_index_xlsx_fr"
      issue = Issue.generate!(:subject => str1, :estimated_hours => '1234.5')
      op, v = make_action_controller_permitted_parameters({'subject' => '='}, {'subject' => [str1]})

      get :index, :params => {:project_id => 1,
                              :f => ['subject'],
                              :op => op,
                              :v => v,
                              :c => ['estimated_hours', 'subject'],
                              :format => 'xlsx',
                              :set_filter => 1}
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
    end
  end

  def test_index_xlsx_when_specified_unknown_format
    begin
      get :index, :params => {:format => 'unknownformat'}
    rescue ActionController::UnknownFormat => e
      pass
    end
  end

  def test_index_xlsx_should_not_change_selected_columns
    get :index, :params => {
        :set_filter => 1,
        :c => ["subject", "due_date"],
        :project_id => "ecookbook"
    }
    assert_response :success
    assert_equal [:subject, :due_date], column_names
    get :index, :params => {
        :set_filter => 1,
        :c =>["all_inline"],
        :project_id => "ecookbook",
        :format => 'xlsx'
    }
    assert_response :success
    assert_equal [:subject, :due_date], column_names
  end
end