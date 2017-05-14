class FilesQueryColumn < QueryColumn

  def caption
    l(:label_attachment_plural)
  end

  def value(issue)
    issue.attachments.map {|a| a.filename}.join("\n")
  end

end