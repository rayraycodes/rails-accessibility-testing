# frozen_string_literal: true

module RailsAccessibilityTesting
  # Finds line numbers for elements in source files
  # Used by static file scanner to report exact file locations
  #
  # @api private
  class LineNumberFinder
    def initialize(file_content)
      @file_content = file_content
      @lines = file_content.split("\n")
    end

    # Find line number for an element based on its context
    # @param element_context [Hash] Element context with tag, id, src, href, etc.
    # @return [Integer, nil] Line number (1-indexed) or nil if not found
    def find_line_number(element_context)
      return nil unless element_context && @file_content

      tag_name = element_context[:tag]
      id = element_context[:id]
      src = element_context[:src]
      href = element_context[:href]
      type = element_context[:input_type] || element_context[:type]

      @lines.each_with_index do |line, index|
        # Must contain the tag name
        next unless line.include?("<#{tag_name}") || (tag_name && line.include?("<#{tag_name.upcase}"))

        # Try to match by ID first (most specific)
        if id.present? && line.include?("id=") && line.include?(id)
          id_match = line.match(/id=["']([^"']+)["']/)
          return index + 1 if id_match && id_match[1] == id
        end

        # Try to match by src (for images)
        if src.present? && line.include?("src=") && line.include?(src)
          return index + 1
        end

        # Try to match by href (for links)
        if href.present? && line.include?("href=") && line.include?(href)
          return index + 1
        end

        # Try to match by type (for inputs)
        if type.present? && line.include?("type=") && line.include?(type)
          return index + 1
        end

        # If no specific attributes, check if this is likely the element
        if tag_name && line.match(/<#{tag_name}[^>]*>/)
          return index + 1
        end
      end

      nil
    end
  end
end

