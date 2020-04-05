require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectsControllerTest < ActionController::TestCase
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

  def test_index_xlsx_with_all_columns
    get :index, :params => {:format => 'xlsx', :xlsx => {:columns => 'all'}}
    assert_response :success
    assert_equal 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @response.content_type
  end

  def test_index_xlsx_when_specified_unknown_format
    begin
      get :index, :params => {:format => 'unknownformat'}
    rescue ActionController::UnknownFormat => e
      pass
    end
  end
end