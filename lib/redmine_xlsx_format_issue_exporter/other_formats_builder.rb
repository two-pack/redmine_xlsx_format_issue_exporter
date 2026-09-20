# frozen_string_literal: true

require 'redmine/views/other_formats_builder'

module RedmineXlsxFormatIssueExporter
  # Builds the links to the other formats, keeping the query parameters when the view supports it.
  class OtherFormatsBuilder < Redmine::Views::OtherFormatsBuilder
    def link_to(name, options = {})
      return link_to_with_query_parameters(name, {}, options) if respond_to?(:link_to_with_query_parameters)

      super
    end
  end
end
