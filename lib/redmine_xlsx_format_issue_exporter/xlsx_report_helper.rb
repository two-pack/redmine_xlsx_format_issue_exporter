require 'write_xlsx'

module RedmineXlsxFormatIssueExporter
  module XlsxReportHelper
    include TimelogHelper
    include XlsxExportHelper

    def report_to_xlsx(report)
      stream = StringIO.new('')
      workbook = WriteXLSX.new(stream)
      worksheet = workbook.add_worksheet

      columns_width = []

      # Column headers
      headers =
        report.criteria.collect do |criteria|
          l_or_humanize(report.available_criteria[criteria][:label])
        end
      headers += report.periods
      headers << l(:label_total_time)

      start_period_index = headers.count
      worksheet.freeze_panes(1, start_period_index)  # Freeze header row and criteria column.
      write_header_row(workbook, worksheet, headers, columns_width)

      # Content
      row_index = 0
      row_index = report_criteria_to_xlsx(workbook, worksheet, row_index, start_period_index, columns_width,report.available_criteria, report.columns, report.criteria, report.periods, report.hours)

      # Total row
      str_total = l(:label_total_time)
      row = [ str_total ] + [''] * (report.criteria.size - 1)
      total = 0
      report.periods.each do |period|
        sum = sum_hours(select_hours(report.hours, report.columns, period.to_s))
        total += sum
        row << (sum > 0 ? sum : '')
      end
      row << total
      write_item_row(workbook, worksheet, row, row_index, start_period_index, columns_width)
      row_index += 1

      headers.size.times do |index|
        worksheet.set_column(index, index, columns_width[index])
      end

      workbook.close

      stream.string
    end

    def report_criteria_to_xlsx(workbook, worksheet, row_index, start_period_index, columns_width, available_criteria, columns, criteria, periods, hours, level=0)
      hours.collect {|h| h[criteria[level]].to_s}.uniq.each do |value|
        hours_for_value = select_hours(hours, criteria[level], value)
        next if hours_for_value.empty?
        row = [''] * level
        row << format_criteria_value(available_criteria[criteria[level]], value, false).to_s
        row += [''] * (criteria.length - level - 1)
        total = 0
        periods.each do |period|
          sum = sum_hours(select_hours(hours_for_value, columns, period.to_s))
          total += sum
          row << (sum > 0 ? sum : '')
        end
        row << total
        #csv << row
        write_item_row(workbook, worksheet, row, row_index, start_period_index, columns_width)
        row_index += 1
        if criteria.length > level + 1
          row_index = report_criteria_to_xlsx(workbook, worksheet, row_index, start_period_index, columns_width, available_criteria, columns, criteria, periods, hours_for_value, level + 1)
        end
      end
      row_index
    end

    def write_item_row(workbook, worksheet, row, row_index, start_period_index, columns_width)
      hyperlink_format = create_hyperlink_format(workbook)
      info_format = create_cell_format(workbook)
      period_format = create_period_format(workbook)
      row.each_with_index do |value, column_index|
        if column_index < start_period_index
          cell_format = info_format
        else
          cell_format = period_format
        end

        write_item(worksheet, value, row_index, column_index, cell_format, false, nil, hyperlink_format)

        width = get_column_width(value)
        columns_width[column_index] = width if columns_width[column_index] < width
      end
    end

    def create_period_format(workbook)
      workbook.add_format(:border => 1,
                          :text_wrap => 1,
                          :valign => 'top',
                          :num_format => '0.00')
    end

    def format_criteria_value_str(criteria_options, value)
      if method(:format_criteria_value).parameters.include?([:opt, :html])
        format_criteria_value(criteria_options, value, false).to_s
      else
        format_criteria_value(criteria_options, value).to_s
      end
    end

  end
end