require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class FilesQueryColumnTest < ActiveSupport::TestCase
  fixtures :issues, :attachments

  def setup
    @sut = FilesQueryColumn.new(:files)
  end

  def teardown

  end

  def test_that_issue_has_no_files
    issue_without_files = Issue.find(1)

    assert_equal '', @sut.value(issue_without_files)
  end

  def test_that_issue_has_a_file_without_description
    issue_with_a_file = Issue.find(2)

    assert_equal 'picture.jpg', @sut.value(issue_with_a_file)
  end

  def test_that_issue_has_files_with_description
    issue_with_a_file = Issue.find(3)
    expected = "error281.txt\n" +
               "source.rb : This is a Ruby source file\n" +
               "changeset_iso8859-1.diff\n" +
               "archive.zip\n" +
               "changeset_utf8.diff"

    assert_equal expected, @sut.value(issue_with_a_file)
  end

  def test_that_caption_is_files
    assert_equal 'Files', @sut.caption
  end

end