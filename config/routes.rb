RedmineApp::Application.routes.draw do
  match 'projects/:project_id/xlsx_export', :to => 'xlsx_export#index'
  match 'xlsx_export', :to => 'xlsx_export#index'
end