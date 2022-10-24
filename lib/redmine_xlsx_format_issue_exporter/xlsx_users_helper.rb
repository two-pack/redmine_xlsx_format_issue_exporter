require 'write_xlsx'

module RedmineXlsxFormatIssueExporter
  module XlsxUsersHelper
    include UsersHelper
    include XlsxExportHelper

    def users_to_xlsx(users)
      columns = [
        'login',
        'firstname',
        'lastname',
        'mail',
        'admin',
        'status',
        'twofa_scheme',
        'created_on',
        'updated_on',
        'last_login_on',
        'passwd_changed_on'
      ]
      user_custom_fields = UserCustomField.sorted

      stream = StringIO.new('')
      workbook = WriteXLSX.new(stream)
      worksheet = workbook.add_worksheet

      worksheet.freeze_panes(1, 1)  # Freeze header row and Login column.

      columns_width = []
      write_header_row(workbook, worksheet, columns.map{|column| l('field_' + column)} + user_custom_fields.pluck(:name), columns_width)

      hyperlink_format = create_hyperlink_format(workbook)
      cell_format = create_cell_format(workbook)
      users = users.preload(:custom_values)
      users.each_with_index do |user, item_index|
        (columns + user_custom_fields.pluck(:name)).each_with_index do |column, column_index|
          value = columns.include?(column) ? xlsx_content_users(column, user) : user.custom_value_for(user_custom_fields[column_index - columns.length])
          write_item(worksheet, value, item_index, column_index, cell_format, false, 0, hyperlink_format)

          width = get_column_width(value)
          columns_width[column_index] = width if columns_width[column_index] < width
        end
      end

      columns.size.times do |index|
        worksheet.set_column(index, index, columns_width[index])
      end

      workbook.close

      stream.string
    end

    private

    def xlsx_content_users(column_name, user)
      case column_name
      when 'status'
        l("status_#{User::LABEL_BY_STATUS[user.status]}")
      when 'twofa_scheme'
        if user.twofa_active?
          l("twofa__#{user.twofa_scheme}__name")
        else
          l(:label_disabled)
        end
      else
        format_object(user.send(column_name), false)
      end
    end

  end
end