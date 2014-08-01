class FilesQueryColumn < QueryColumn

  def caption
    l(:label_attachment_plural)
  end

  def value(issue)
    return '' unless issue.attachments.any?

    value = ''
    issue.attachments.each do |attachment|
      value << attachment.filename
      if attachment.description?
        value << ' : ' + attachment.description
      end
      value << "\n" unless attachment == issue.attachments.last
    end

    value
  end

end