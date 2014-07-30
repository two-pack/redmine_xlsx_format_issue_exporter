# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class XlsxExportHelperTest < Test::Unit::TestCase

  include XlsxExportHelper

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

end