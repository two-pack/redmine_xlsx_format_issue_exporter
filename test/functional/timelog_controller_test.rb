require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TimelogControllerTest < ActionController::TestCase
  fixtures :projects, :enabled_modules, :roles, :members,
           :member_roles, :email_addresses, :issues, :time_entries, :users,
           :trackers, :enumerations, :issue_statuses,
           :custom_fields, :custom_values,
           :projects_trackers, :custom_fields_trackers,
           :custom_fields_projects

  include Redmine::I18n
  include RedmineXlsxFormatIssueExporter

  def params_for_create(attributes = nil)
    if (Redmine::VERSION::MAJOR <= 3) or (Redmine::VERSION::MAJOR == 4) then
      attributes.delete(:author)
    end
    attributes
  end

  def setup
    Setting.default_language = "en"
  end

  def test_index_at_project_level_should_include_xlsx_export_dialog
    op, v = make_action_controller_permitted_parameters({'spent_on' => '>='}, {'spent_on' => ['2007-04-01']})

    get :index,
        :params => {:project_id => 'ecookbook',
                    :f => ['spent_on'],
                    :op => op,
                    :v => v,
                    :c => ['spent_on', 'user']}
    assert_response :success

    assert_select '#xlsx-export-options' do
      assert_select 'form[action=?][method=get]', '/projects/ecookbook/time_entries.xlsx' do
        # filter
        assert_select 'input[name=?][value=?]', 'f[]', 'spent_on'
        assert_select 'input[name=?][value=?]', 'op[spent_on]', '>='
        assert_select 'input[name=?][value=?]', 'v[spent_on][]', '2007-04-01'
        # columns
        assert_select 'input[name=?][type=hidden][value=?]', 'c[]', 'spent_on'
        assert_select 'input[name=?][type=hidden][value=?]', 'c[]', 'user'
        assert_select 'input[name=?][type=hidden]', 'c[]', 2
        assert_select 'input[name=?][value=?]', 'c[]', 'all_inline'
      end
    end
  end

  def test_index_cross_project_should_include_xlsx_export_dialog
    get :index
    assert_response :success

    assert_select '#xlsx-export-options' do
      assert_select 'form[action=?][method=get]', '/time_entries.xlsx'
    end
  end

  def test_index_xlsx_all_projects
    with_settings :date_format => '%m/%d/%Y' do
      get :index, :params => {:format => 'xlsx'}
      assert_response :success
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', response.content_type
    end
  end

  def test_index_xlsx
    with_settings :date_format => '%m/%d/%Y' do
      get :index, :params => {:project_id => 1, :format => 'xlsx'}
      assert_response :success
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', response.content_type
    end
  end

  def test_index_xlsx_when_specified_unknown_format
    begin
      get :index, :params => {:format => 'unknownformat'}
    rescue ActionController::UnknownFormat => e
      pass
    end
  end

  def test_report_all_projects_xlsx_export
    get :report,
        :params => {:columns => 'month',
                    :from => "2007-01-01",
                    :to => "2007-06-30",
                    :criteria => ["project", "user", "activity"],
                    :format => "xlsx"}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_report_xlsx_export
    get :report,
        :params => {:project_id => 1,
                    :columns => 'month',
                    :from => "2007-01-01",
                    :to => "2007-06-30",
                    :criteria => ["project", "user", "activity"],
                    :format => "xlsx"}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_xlsx_big_5
    str_utf8  = "\xe4\xb8\x80\xe6\x9c\x88".force_encoding('UTF-8')
    str_big5  = "\xa4@\xa4\xeb".force_encoding('Big5')
    user = User.find_by_id(3)
    user.firstname = str_utf8
    user.lastname  = "test-lastname"
    assert user.save
    comments = "test_xlsx_big_5"
    te1 = TimeEntry.create(params_for_create(
                           :spent_on => '2011-11-11',
                           :hours    => 7.3,
                           :project  => Project.find(1),
                           :author   => user,
                           :user     => user,
                           :activity => TimeEntryActivity.find_by_name('Design'),
                           :comments => comments))

    te2 = TimeEntry.find_by_comments(comments)
    assert_not_nil te2
    assert_equal 7.3, te2.hours
    assert_equal 3, te2.user_id

    with_settings :default_language => "zh-TW" do
      get :report,
          :params => {:project_id => 1,
                      :columns => 'day',
                      :from => "2011-11-11",
                      :to => "2011-11-11",
                      :criteria => ["user"],
                      :format => "xlsx"}
    end
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_xlsx_cannot_convert_should_be_replaced_big_5
    str_utf8  = "\xe4\xbb\xa5\xe5\x86\x85".force_encoding('UTF-8')
    user = User.find_by_id(3)
    user.firstname = str_utf8
    user.lastname  = "test-lastname"
    assert user.save
    comments = "test_replaced"
    te1 = TimeEntry.create(params_for_create(
                           :spent_on => '2011-11-11',
                           :hours    => 7.3,
                           :project  => Project.find(1),
                           :author   => user,
                           :user     => user,
                           :activity => TimeEntryActivity.find_by_name('Design'),
                           :comments => comments))

    te2 = TimeEntry.find_by_comments(comments)
    assert_not_nil te2
    assert_equal 7.3, te2.hours
    assert_equal 3, te2.user_id

    with_settings :default_language => "zh-TW" do
      get :report,
          :params => {:project_id => 1,
                      :columns => 'day',
                      :from => "2011-11-11",
                      :to => "2011-11-11",
                      :criteria => ["user"],
                      :format => "xlsx"}
    end
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_xlsx_fr
    with_settings :default_language => "fr" do
      str1  = "test_xlsx_fr"
      user = User.find_by_id(3)
      te1 = TimeEntry.create(params_for_create(
                             :spent_on => '2011-11-11',
                             :hours    => 7.3,
                             :project  => Project.find(1),
                             :author   => user,
                             :user     => user,
                             :activity => TimeEntryActivity.find_by_name('Design'),
                             :comments => str1))

      te2 = TimeEntry.find_by_comments(str1)
      assert_not_nil te2
      assert_equal 7.3, te2.hours
      assert_equal 3, te2.user_id

      get :report,
          :params => {:project_id => 1,
                      :columns => 'day',
                      :from => "2011-11-11",
                      :to => "2011-11-11",
                      :criteria => ["user"],
                      :format => "xlsx"}
      assert_response :success
      assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
    end
  end

  def test_report_xlsx_when_specified_unknown_format
    begin
      get :report, :params => {:format => 'unknownformat'}
    rescue ActionController::UnknownFormat => e
      pass
    end
  end
end