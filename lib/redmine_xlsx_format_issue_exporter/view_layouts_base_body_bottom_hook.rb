module RedmineXlsxFormatIssueExporter
  class ViewLayoutsBaseBodyBootomHook < Redmine::Hook::ViewListener

    def view_layouts_base_body_bottom(context={})
      call_from = [context[:controller].controller_name, context[:controller].action_name]
      if call_from == ["issues", "index"]
        layout = 'hooks/xlsx_export_dialog_on_issues_index'
      elsif call_from == ["timelog", "index"]
        layout ='hooks/xlsx_export_dialog_on_timelog_index'
      elsif call_from == ["timelog", "report"]
        layout ='hooks/insert_xlsx_link_for_download'
      else
        return
      end

      context[:hook_caller].send(:render, {:locals => context}.merge(:partial => layout))
    end
  end
end
