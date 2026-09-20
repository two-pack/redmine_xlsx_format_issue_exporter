# frozen_string_literal: true

module RedmineXlsxFormatIssueExporter
  class ViewLayoutsBaseBodyBottomHook < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context = {})
      return unless context[:controller].status == 200

      call_from = [context[:controller].controller_name, context[:controller].action_name]
      case call_from
      when %w[issues index]
        layout = 'hooks/xlsx_export_dialog_on_issues_index'
      when %w[timelog index]
        layout = 'hooks/xlsx_export_dialog_on_timelog_index'
      when %w[timelog report]
        layout = 'hooks/insert_xlsx_link_for_download'
      when %w[projects index]
        layout = 'hooks/xlsx_export_dialog_on_projects_index'
      when %w[users index]
        layout = if (Redmine::VERSION::MAJOR == 5) && Redmine::VERSION::MINOR.zero?
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
