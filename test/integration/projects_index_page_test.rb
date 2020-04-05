require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

if (Redmine::VERSION::MAJOR >= 5) || (Redmine::VERSION::BRANCH == 'devel') then
  require File.expand_path(File.dirname(__FILE__) + '/projects_index_page_41x')
  require File.expand_path(File.dirname(__FILE__) + '/projects_index_page_latest')
elsif ((Redmine::VERSION::MAJOR == 4) && (Redmine::VERSION::MINOR >= 1))
  require File.expand_path(File.dirname(__FILE__) + '/projects_index_page_41x')
else
  require File.expand_path(File.dirname(__FILE__) + '/projects_index_page_40x')
end
