require 'redmine/views/other_formats_builder'

module RedmineXlsxFormatIssueExporter
  class OtherFormatsBuilder < Redmine::Views::OtherFormatsBuilder
    def link_to(name, options={})
      if respond_to?(:link_to_with_query_parameters)
        return link_to_with_query_parameters(name, {}, options)
      end
      super
    end
  end
end