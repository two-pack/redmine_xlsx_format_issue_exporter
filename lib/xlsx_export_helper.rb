require 'write_xlsx'

module XlsxExportHelper

  def query_to_xlsx(items, query, options={})
    columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
    query.available_block_columns.each do |column|
      if options[column.name].present?
        columns << column
      end
    end
    export_to_xlsx(items, columns)
  end

  def export_to_xlsx(items, columns)
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

  def write_item_rows(workbook, worksheet, columns, items, columns_width)
    hyperlink_format = create_hyperlink_format(workbook)
    cell_format = create_cell_format(workbook)
    items.each_with_index do |item, item_index|
      columns.each_with_index do |c, column_index|
        value = xlsx_content(c, item)
        write_item(worksheet, value, item_index, column_index, cell_format, c, item.id, hyperlink_format)

        width = get_column_width(value)
        columns_width[column_index] = width if columns_width[column_index] < width
      end
    end
  end

  def write_item(worksheet, value, row_index, column_index, cell_format, column, id, hyperlink_format)
    if column.name == :id
      issue_url = url_for(:controller => 'issues', :action => 'show', :id => id)
      worksheet.write(row_index + 1, column_index, issue_url, hyperlink_format, value)
    else
      worksheet.write(row_index + 1, column_index, value, cell_format)
    end
  end

  def write_header_row(workbook, worksheet, columns, columns_width)
    header_format = create_header_format(workbook)
    columns.each_with_index do |c, index|
      value = c.caption.to_s
      worksheet.write(0, index, value, header_format)
      columns_width << get_column_width(value)
    end
  end

  def xlsx_content(column, issue)
    value = column.value(issue)
    if value.is_a?(Array)
      value.collect {|v| xlsx_value(issue, v)}.compact.join(', ')
    else
      xlsx_value(issue, value)
    end
  end

  def xlsx_value(issue, value)
    case value.class.name
      when 'Time'
        format_time(value)
      when 'Date'
        format_date(value)
      when 'Float'
        sprintf("%.2f", value).gsub('.', l(:general_csv_decimal_separator))
      when 'IssueRelation'
        other = value.other_issue(issue)
        l(value.label_for(issue)) + " ##{other.id}"
      when 'TrueClass'
        l(:general_text_Yes)
      when 'FalseClass'
        l(:general_text_No)
      when 'String'
        value.gsub(/\r\n/, "\n")
      else
        value.to_s
    end
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

  def get_column_width(value)
    width = (value.length + value.chars.reject(&:ascii_only?).length) * 1.1  # 1.1: margin
    width > 30 ? 30 : width  # 30: max width
  end

end