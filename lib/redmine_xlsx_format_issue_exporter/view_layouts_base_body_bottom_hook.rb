module RedmineXlsxFormatIssueExporter
  class ViewLayoutsBaseBodyBottomHook < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context = {})
      return unless context[:controller].status == 200

      call_from = [context[:controller].controller_name, context[:controller].action_name]
      if call_from == %w[issues index]
        layout = 'hooks/xlsx_export_dialog_on_issues_index'
      elsif call_from == %w[timelog index]
        layout = 'hooks/xlsx_export_dialog_on_timelog_index'
      elsif call_from == %w[timelog report]
        layout = 'hooks/insert_xlsx_link_for_download'
      elsif call_from == %w[projects index]
        layout = 'hooks/xlsx_export_dialog_on_projects_index'
      elsif call_from == %w[users index]
        layout = if (Redmine::VERSION::MAJOR == 5) && (Redmine::VERSION::MINOR == 0)
                   'hooks/insert_xlsx_link_for_download'
                 else
                   'hooks/xlsx_export_dialog_on_users_index'
                 end
      else
        return
      end

      context[:hook_caller].send(:render, { locals: context }.merge(partial: layout))
    end
  end
end
