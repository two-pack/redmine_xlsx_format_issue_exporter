class IssuesPageHooks < Redmine::Hook::ViewListener
  render_on :view_issues_index_bottom,
            :partial => 'hooks/view_issues_index_bottom'
end