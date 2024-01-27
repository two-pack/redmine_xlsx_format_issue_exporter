require 'write_xlsx'

module RedmineXlsxFormatIssueExporter
  module XlsxExportHelper

    def query_to_xlsx(items, query, options={})
      columns = query.columns

      stream = StringIO.new('')
      workbook = WriteXLSX.new(stream)
      worksheet = workbook.add_worksheet

      worksheet.freeze_panes(1, 1)  # Freeze header row and # column.

      columns_width = []
      write_header_row(workbook, worksheet, columns, columns_width)
      write_item_rows(workbook, worksheet, columns, items, columns_width)
      columns.size.times do |index|
        worksheet.set_column(index, index, columns_width[index])
      end

      workbook.close

      stream.string
    end

    def write_header_row(workbook, worksheet, columns, columns_width)
      header_format = create_header_format(workbook)
      columns.each_with_index do |c, index|
        if c.class.name == 'String'
            value = c
        else
            value = c.caption.to_s
        end

        worksheet.write(0, index, value, header_format)
        columns_width << get_column_width(value)
      end
    end

    def write_item_rows(workbook, worksheet, columns, items, columns_width)
      hyperlink_format = create_hyperlink_format(workbook)
      cell_format = create_cell_format(workbook)
      items.each_with_index do |item, item_index|
        columns.each_with_index do |c, column_index|
          value = xlsx_content(c, item)
          write_item(worksheet, value, item_index, column_index, cell_format, (c.name == :id), item.id, hyperlink_format)

          width = get_column_width(value)
          columns_width[column_index] = width if columns_width[column_index] < width
        end
      end
    end

    def xlsx_content(column, item)
      csv_content(column, item)
    end

    # Conditions from worksheet.rb in write_xlsx.
    def is_transformed_to_hyperlink?(token)
      return if not token.is_a?(String)
      # Match http, https or ftp URL
      if token =~ %r|\A[fh]tt?ps?://|
        true
        # Match mailto:
      elsif token =~ %r|\Amailto:|
        true
        # Match internal or external sheet link
      elsif token =~ %r!\A(?:in|ex)ternal:!
        true
      end
    end

    def crlf_to_lf(value)
      value.is_a?(String) ? value.gsub(/\r\n?/, "\n") : value
    end

    def write_item(worksheet, value, row_index, column_index, cell_format, is_id_column, id, hyperlink_format)
      if is_id_column
        issue_url = url_for(:controller => 'issues', :action => 'show', :id => id)
        worksheet.write(row_index + 1, column_index, issue_url, hyperlink_format, value)
        return
      end

      if is_transformed_to_hyperlink?(value)
        worksheet.write_string(row_index + 1, column_index, value, cell_format)
        return
      end

      worksheet.write(row_index + 1, column_index, crlf_to_lf(value), cell_format)
    end

    def get_column_width(value)
      value_str = value.to_s
      width = (value_str.length + value_str.chars.reject(&:ascii_only?).length) * 1.1  # 1.1: margin
      width > 30 ? 30 : width  # 30: max width
    end

    def create_header_format(workbook)
      workbook.add_format(:bold => 1,
                          :border => 1,
                          :color => 'white',
                          :bg_color => 'gray',
                          :text_wrap => 1,
                          :valign => 'top')
    end

    def create_cell_format(workbook)
      workbook.add_format(:border => 1,
                          :text_wrap => 1,
                          :valign => 'top')
    end

    def create_hyperlink_format(workbook)
      workbook.add_format(:border => 1,
                          :text_wrap => 1,
                          :valign => 'top',
                          :color => 'blue',
                          :underline => 1)
    end

  end
end