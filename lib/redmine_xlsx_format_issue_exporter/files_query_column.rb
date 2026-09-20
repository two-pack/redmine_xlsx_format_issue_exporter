# frozen_string_literal: true

module RedmineXlsxFormatIssueExporter
  # Query column that lists the file names attached to an issue.
  class FilesQueryColumn < QueryColumn
    def caption
      l(:label_attachment_plural)
    end

    def value(issue)
      issue.attachments.map(&:filename).join("\n")
    end

    def value_object(issue)
      issue.attachments.map(&:filename).join("\n")
    end
  end
end
