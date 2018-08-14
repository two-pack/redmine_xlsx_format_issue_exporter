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
          'created_on',
          'last_login_on',
          'status'
      ]

      stream = StringIO.new('')
      workbook = WriteXLSX.new(stream)
      worksheet = workbook.add_worksheet

      worksheet.freeze_panes(1, 1)  # Freeze header row and Login column.

      columns_width = []
      write_header_row(workbook, worksheet, columns.map{|column| l('field_' + column)}, columns_width)

      hyperlink_format = create_hyperlink_format(workbook)
      cell_format = create_cell_format(workbook)
      users.each_with_index do |user, item_index|
        columns.each_with_index do |column, column_index|
          value = get_cell_value(column, user)
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

    def get_cell_value(column, user)
      if column == 'status'
        l(("status_#{User::LABEL_BY_STATUS[user.status]}"))
      else
        format_object(user.send(column), false)
      end
    end

  end
end