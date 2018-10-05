# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module RedmineXlsxFormatIssueExporter
  class XlsxExportHelperTest < ActiveSupport::TestCase

    include XlsxExportHelper

    def setup
      if @NAME.start_with?('test_write_item_')
        @stream = StringIO.new('')
        @workbook = WriteXLSX.new(@stream)
        @worksheet = @workbook.add_worksheet
        @hyperlink_format = create_hyperlink_format(@workbook)
        @cell_format = create_cell_format(@workbook)
      end
    end

    def teardown
      if @NAME.start_with?('test_write_item_')
        @workbook.close
      end
    end

    def test_to_get_column_width_when_value_length_is_ascii
      # ascii width is 1.1
      assert_equal 10 * 1.1, get_column_width("0123456789")
    end

    def test_to_get_column_width_when_value_has_wide_chars
      # wide char width is 2.2
      assert_equal 7 * 2 * 1.1, get_column_width("あいうえおあお")
    end

    def test_to_get_column_width_when_value_has_ascii_and_wide_chars
      assert_equal 7 * 1.1 + 5 * 2.2, get_column_width("abcdefgあいうえお")
    end

    def test_that_column_width_is_30_when_width_over_30
      assert_equal 30, get_column_width("0123456789012345678901234567")
    end

    def test_that_column_width_is_calculated_when_width_less_than_30
      assert_equal 27 * 1.1, get_column_width("012345678901234567890123456")
    end

    def test_that_column_width_is_30_when_width_over_30_with_wide_char
      assert_equal 30, get_column_width("01234567890123456789012345あ")
    end

    def test_write_item_for_normal_value
      assert_nothing_raised do
        write_item(@worksheet, "example", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_http
      assert_nothing_raised do
        write_item(@worksheet, "http://example.com", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_https
      assert_nothing_raised do
        write_item(@worksheet, "https://example.com", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_ftp
      assert_nothing_raised do
        write_item(@worksheet, "ftp://example.com", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_mailto
      assert_nothing_raised do
        write_item(@worksheet, "mailto:test@example.com", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_internal
      assert_nothing_raised do
        write_item(@worksheet, "internal:Sheet1!A1", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_external
      assert_nothing_raised do
        write_item(@worksheet, "external:c:\foo.xlsx", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_http_and_too_long
      assert_nothing_raised do
        write_item(@worksheet, "http://example.com/01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_started_http_and_too_long2
      assert_nothing_raised do
        write_item(@worksheet, "http://example.com/012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_write_item_for_value_with_crlf
      assert_nothing_raised do
        write_item(@worksheet, "test1\r\ntest2\r\ntest3", 0, 0, @cell_format, false, 1, @hyperlink_format)
      end

      assert_equal false, @worksheet.instance_variable_defined?('@hyperlinks')
    end

    def test_crlf_to_lf_with_crlf_string
      assert_equal "test1\ntest2\ntest3", crlf_to_lf("test1\r\ntest2\r\ntest3")
    end

    def test_crlf_to_lf_with_lf_string
      assert_equal "test1\ntest2\ntest3", crlf_to_lf("test1\ntest2\ntest3")
    end

    def test_crlf_to_lf_with_cr_string
      assert_equal "test1\ntest2\ntest3", crlf_to_lf("test1\rtest2\rtest3")
    end

    def test_crlf_to_lf_with_float
      assert_equal 7.3, crlf_to_lf(7.3)
    end

    def test_crlf_to_lf_with_array
      assert_equal [0, 1, 2], crlf_to_lf([0, 1, 2])
    end

    def test_crlf_to_lf_with_nil
      assert_nil crlf_to_lf(nil)
    end

  end
end