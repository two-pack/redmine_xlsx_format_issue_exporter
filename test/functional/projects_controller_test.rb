require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

if (Redmine::VERSION::MAJOR > 4) or ((Redmine::VERSION::MAJOR == 4) && (Redmine::VERSION::MINOR >= 1))
  require File.expand_path(File.dirname(__FILE__) + '/projects_controller_latest')
end
