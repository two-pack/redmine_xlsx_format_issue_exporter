require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

module RedmineXlsxFormatIssueExporter
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
      assert_equal '', @sut.value_object(issue_without_files)
    end

    def test_that_issue_has_a_file_without_description
      issue_with_a_file = Issue.find(2)
      expected = ""
      if Redmine::VERSION::MAJOR <= 2 then
        expected = "picture.jpg"
      else
        expected = "source.rb\n" +
                   "picture.jpg"
      end

      assert_equal expected, @sut.value(issue_with_a_file)
      assert_equal expected, @sut.value_object(issue_with_a_file)
    end

    def test_that_issue_has_files_with_description
      issue_with_a_file = Issue.find(3)
      expected = ""
      if Redmine::VERSION::MAJOR <= 2 then
        expected = "error281.txt\n" +
                   "source.rb\n" +
                   "changeset_iso8859-1.diff\n" +
                   "archive.zip\n" +
                   "changeset_utf8.diff"
      elsif (Redmine::VERSION::MAJOR == 3) and (Redmine::VERSION::MINOR <= 1) then
        expected = "error281.txt\n" +
                   "changeset_iso8859-1.diff\n" +
                   "archive.zip\n" +
                   "changeset_utf8.diff"
      elsif ((Redmine::VERSION::MAJOR == 3) and (Redmine::VERSION::MINOR >= 2)) or
            (Redmine::VERSION::MAJOR >= 4) then
        expected = "error281.txt\n" +
                   "changeset_iso8859-1.diff\n" +
                   "archive.zip\n" +
                   "changeset_utf8.diff"
      end

      assert_equal expected, @sut.value(issue_with_a_file)
      assert_equal expected, @sut.value_object(issue_with_a_file)
    end

    def test_that_caption_is_files
      I18n.locale = :en

      assert_equal 'Files', @sut.caption
    end

  end
end