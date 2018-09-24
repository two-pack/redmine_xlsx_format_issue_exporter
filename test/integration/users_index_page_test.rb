require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

if ((Redmine::VERSION::MAJOR >= 4) || (Redmine::VERSION::BRANCH == 'devel')) then
  require File.expand_path(File.dirname(__FILE__) + '/users_index_page_latest')
end
