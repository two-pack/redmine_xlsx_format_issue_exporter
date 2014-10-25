RedmineApp::Application.routes.draw do
  get 'projects/:project_id/xlsx_export', :to => 'xlsx_export#index'
  get 'xlsx_export', :to => 'xlsx_export#index'
end