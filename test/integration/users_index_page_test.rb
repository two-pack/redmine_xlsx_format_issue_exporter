require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

if Redmine::VERSION::MAJOR >= 4 then
  require File.expand_path(File.dirname(__FILE__) + '/users_index_page_latest')
end
