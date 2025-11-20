# frozen_string_literal: true

require 'nokogiri'
require 'fileutils'
require_relative 'static_page_adapter'
require_relative 'engine/rule_engine'
require_relative 'config/yaml_loader'

module RailsAccessibilityTesting
  # Static file scanner that scans view files directly without visiting pages
  # Uses the existing RuleEngine and checks from the checks/ folder
  # Reports errors with exact file locations and line numbers
  class StaticFileScanner
    attr_reader :view_file, :violations

    def initialize(view_file)
      @view_file = view_file
      @file_content = nil
      @violations = []
    end

    # Scan the view file for accessibility issues using existing RuleEngine
    def scan
      return { errors: [], warnings: [] } unless File.exist?(@view_file)

      @file_content = File.read(@view_file)

      # Extract HTML from ERB template
      html_content = extract_html_from_erb(@file_content)

      # Create static page adapter (makes Nokogiri look like Capybara)
      static_page = StaticPageAdapter.new(html_content, view_file: @view_file)

      # Load config and create engine (reuse existing infrastructure)
      begin
        config = Config::YamlLoader.load(profile: :test)
        engine = Engine::RuleEngine.new(config: config)

        # Context for violations
        context = {
          url: nil,
          path: nil,
          view_file: @view_file
        }

        # Run all checks using existing RuleEngine
        @violations = engine.check(static_page, context: context)

        # Convert violations to errors/warnings format with line numbers
        convert_violations_to_errors_and_warnings

        { errors: @errors, warnings: @warnings }
      rescue StandardError => e
        # If engine fails, return empty results
        { errors: [], warnings: [] }
      end
    end

    attr_reader :errors, :warnings

    private

    # Convert violations to errors/warnings format with line numbers
    def convert_violations_to_errors_and_warnings
      @errors = []
      @warnings = []

      @violations.each do |violation|
        element_context = violation.element_context || {}
        line_num = find_line_number_for_element(element_context)

        error_data = {
          type: violation.message,
          element: element_context,
          file: @view_file,
          line: line_num,
          wcag: violation.wcag_reference
        }

        # Skip links and aria landmarks are warnings, everything else is an error
        if violation.message.include?('skip link') || violation.message.include?('Skip link') ||
           (violation.rule_name == 'aria_landmarks')
          @warnings << error_data
        else
          @errors << error_data
        end
      end
    end

    # Find line number for an element based on its context
    def find_line_number_for_element(element_context)
      return nil unless element_context && @file_content

      tag_name = element_context[:tag]
      id = element_context[:id]
      src = element_context[:src]
      href = element_context[:href]
      type = element_context[:input_type] || element_context[:type]

      # Search for this element in the original file content
      @file_content.split("\n").each_with_index do |line, index|
        # Must contain the tag name and opening bracket
        next unless line.include?("<#{tag_name}") || (tag_name && line.include?("<#{tag_name.upcase}"))

        # Try to match by ID first (most specific)
        if id.present? && line.include?("id=") && line.include?(id)
          id_match = line.match(/id=["']([^"']+)["']/)
          if id_match && id_match[1] == id
            return index + 1
          end
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

    # Extract HTML from ERB template (remove Ruby code, keep HTML)
    def extract_html_from_erb(content)
      # Remove ERB tags but keep the HTML structure
      # This is a simplified approach - for production, might want more sophisticated parsing
      html = content.dup

      # Remove ERB code blocks but preserve line structure
      html.gsub!(/<%[^%]*%>/, '')
      html.gsub!(/<%=.*?%>/, '')

      # Clean up extra whitespace
      html.gsub!(/\n\s*\n\s*\n/, "\n\n")

      html
    end
  end
end

