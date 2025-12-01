# frozen_string_literal: true

require 'nokogiri'
require_relative 'view_composition_builder'
require_relative 'erb_extractor'

module RailsAccessibilityTesting
  # Scans a complete composed page (layout + view + partials) for heading hierarchy
  # This ensures heading hierarchy is checked across the entire page, not just individual files
  #
  # @api private
  class ComposedPageScanner
    def initialize(view_file)
      @view_file = view_file
      @builder = ViewCompositionBuilder.new(view_file)
    end

    # Scan the complete composed page for heading hierarchy violations
    # @return [Hash] Hash with :errors and :warnings arrays
    def scan_heading_hierarchy
      return { errors: [], warnings: [] } unless @view_file && File.exist?(@view_file)

      # Build composition
      all_files = @builder.build
      return { errors: [], warnings: [] } if all_files.empty?

      # Get all headings from complete composition
      headings = @builder.all_headings
      return { errors: [], warnings: [] } if headings.empty?

      violations = []

      # Check 1: Missing H1
      h1_count = headings.count { |h| h[:level] == 1 }
      first_heading = headings.first

      if h1_count == 0
        if first_heading
          violations << create_violation(
            message: "Page has h#{first_heading[:level]} but no h1 heading (checked complete page: layout + view + partials)",
            heading: first_heading,
            wcag_reference: "1.3.1",
            remediation: "Add an <h1> heading to your page. The H1 can be in the layout, view, or a partial:\n\n<h1>Main Page Title</h1>"
          )
        else
          violations << create_violation(
            message: "Page missing H1 heading (checked complete page: layout + view + partials)",
            heading: nil,
            wcag_reference: "1.3.1",
            remediation: "Add an <h1> heading to your page. The H1 can be in the layout, view, or a partial:\n\n<h1>Main Page Title</h1>"
          )
        end
      end

      # Check 2: Multiple H1s
      if h1_count > 1
        h1_headings = headings.select { |h| h[:level] == 1 }
        h1_headings[1..-1].each do |h1|
          violations << create_violation(
            message: "Page has multiple h1 headings (#{h1_count} total) - only one h1 should be used per page (checked complete page: layout + view + partials)",
            heading: h1,
            wcag_reference: "1.3.1",
            remediation: "Use only one <h1> per page. Convert additional h1s to h2 or lower:\n\n<h1>Main Title</h1>\n<h2>Section Title</h2>"
          )
        end
      end

      # Check 3: Heading hierarchy skipped levels
      # Only flag if we're skipping from a real heading (not from h0)
      # If the first heading is h2, that's fine - it just means no h1 exists (handled by Check 1)
      previous_level = nil
      headings.each do |heading|
        current_level = heading[:level]
        if previous_level && current_level > previous_level + 1
          # Only flag if we're skipping from a real heading level
          violations << create_violation(
            message: "Heading hierarchy skipped (h#{previous_level} to h#{current_level}) - checked complete page: layout + view + partials",
            heading: heading,
            wcag_reference: "1.3.1",
            remediation: "Fix the heading hierarchy. Don't skip levels. Use h#{previous_level + 1} instead of h#{current_level}."
          )
        end
        previous_level = current_level
      end

      # Convert to errors/warnings format (matching ViolationConverter format)
      errors = violations.map do |v|
        {
          type: v[:message],
          element: {
            tag: v[:heading] ? "h#{v[:heading][:level]}" : 'page',
            text: v[:heading] ? v[:heading][:text] : 'Page-level heading hierarchy check',
            file: v[:file] || @view_file
          },
          file: v[:file] || @view_file,
          line: v[:line] || 1,
          wcag: v[:wcag_reference],
          remediation: v[:remediation],
          page_level_check: true,
          check_type: 'heading_hierarchy'
        }
      end

      { errors: errors, warnings: [] }
    end
    
    # Scan the complete composed page for all heading issues (not just hierarchy)
    # This includes: empty headings, styling-only headings, etc.
    # @return [Hash] Hash with :errors and :warnings arrays
    def scan_all_headings
      return { errors: [], warnings: [] } unless @view_file && File.exist?(@view_file)
      
      # Build composition
      all_files = @builder.build
      return { errors: [], warnings: [] } if all_files.empty?
      
      # Get all headings from complete composition
      headings = @builder.all_headings
      return { errors: [], warnings: [] } if headings.empty?
      
      errors = []
      warnings = []
      
      # Check for empty headings (across complete page)
      headings.each do |heading|
        heading_text = heading[:text]
        
        # Check if heading contains ERB placeholder
        has_erb_content = heading_text.include?('ERB_CONTENT')
        
        # Check if heading is empty or only contains whitespace
        if (heading_text.empty? || heading_text.match?(/^\s*$/)) && !has_erb_content
          errors << {
            type: "Empty heading detected (<h#{heading[:level]}>) - headings must have accessible text (checked complete page: layout + view + partials)",
            element: {
              tag: "h#{heading[:level]}",
              text: 'Empty heading',
              file: heading[:file]
            },
            file: heading[:file],
            line: heading[:line],
            wcag: "4.1.2",
            remediation: "Add descriptive text to the heading:\n\n<h#{heading[:level]}>Descriptive Heading Text</h#{heading[:level]}>",
            page_level_check: true,
            check_type: 'heading_empty'
          }
        end
        
        # Check for styling-only headings (very short or generic text)
        if heading_text.length <= 2 && heading_text.match?(/^[•→…\s\-_=]+$/)
          warnings << {
            type: "Heading appears to be used for styling only (text: '#{heading_text}') - headings should be descriptive (checked complete page: layout + view + partials)",
            element: {
              tag: "h#{heading[:level]}",
              text: heading_text,
              file: heading[:file]
            },
            file: heading[:file],
            line: heading[:line],
            wcag: "2.4.6",
            remediation: "Use CSS for styling instead of headings. Replace with a <div> or <span> with appropriate CSS classes.",
            page_level_check: true,
            check_type: 'heading_styling'
          }
        end
      end
      
      { errors: errors, warnings: warnings }
    end
    
    # Scan the complete composed page for duplicate IDs
    # IDs must be unique across the entire page (layout + view + partials)
    # @return [Hash] Hash with :errors and :warnings arrays
    def scan_duplicate_ids
      return { errors: [], warnings: [] } unless @view_file && File.exist?(@view_file)
      
      # Build composition
      all_files = @builder.build
      return { errors: [], warnings: [] } if all_files.empty?
      
      # Collect all IDs from complete composition
      id_map = {} # id => [{ file: String, line: Integer, element: String }]
      
      all_files.each do |file|
        # Handle both relative and absolute paths
        file_path = if File.exist?(file)
          file
        elsif defined?(Rails) && Rails.root
          rails_path = Rails.root.join(file)
          rails_path.exist? ? rails_path.to_s : nil
        else
          nil
        end
        next unless file_path && File.exist?(file_path)
        
        content = File.read(file_path)
        html_content = ErbExtractor.extract_html(content)
        doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
        
        # Find all elements with IDs
        doc.css('[id]').each do |element|
          id = element[:id]
          next if id.nil? || id.to_s.strip.empty?
          # Skip ERB_CONTENT placeholder - it's not a real ID
          next if id == 'ERB_CONTENT'
          
          id_map[id] ||= []
          line = find_line_number_for_element(content, element)
          id_map[id] << {
            file: file_path,  # Use resolved path
            line: line,
            element: element.name
          }
        end
      end
      
      errors = []
      
      # Find duplicate IDs
      id_map.each do |id, occurrences|
        if occurrences.length > 1
          # Report all occurrences after the first one
          occurrences[1..-1].each do |occurrence|
            errors << {
              type: "Duplicate ID '#{id}' found (checked complete page: layout + view + partials) - IDs must be unique across the entire page",
              element: {
                tag: occurrence[:element],
                id: id,
                file: occurrence[:file]
              },
              file: occurrence[:file],
              line: occurrence[:line],
              wcag: "4.1.1",
              remediation: "Remove or rename the duplicate ID. Each ID must be unique on the page:\n\n<!-- Change one of these -->\n<div id=\"#{id}\">...</div>\n<div id=\"#{id}\">...</div>\n\n<!-- To -->\n<div id=\"#{id}\">...</div>\n<div id=\"#{id}-2\">...</div>",
              page_level_check: true,
              check_type: 'duplicate_ids'
            }
          end
        end
      end
      
      { errors: errors, warnings: [] }
    end
    
    # Helper to find line number for an element
    def find_line_number_for_element(content, element)
      tag_name = element.name
      id = element[:id]
      
      lines = content.split("\n")
      lines.each_with_index do |line, index|
        if line.include?("<#{tag_name}") && (id.nil? || line.include?("id=\"#{id}\"") || line.include?("id='#{id}'"))
          return index + 1
        end
      end
      
      1
    end
    
    # Scan the complete composed page for ARIA landmarks
    # This ensures landmarks in layout are detected when scanning view files
    # @return [Hash] Hash with :errors and :warnings arrays
    def scan_aria_landmarks
      return { errors: [], warnings: [] } unless @view_file && File.exist?(@view_file)
      
      # Build composition
      all_files = @builder.build
      return { errors: [], warnings: [] } if all_files.empty?
      
      # Check for main landmark across all files
      has_main = false
      main_location = nil
      
      all_files.each do |file|
        next unless File.exist?(file)
        
        content = File.read(file)
        html_content = ErbExtractor.extract_html(content)
        doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
        
        # Check for <main> tag or [role="main"]
        main_elements = doc.css('main, [role="main"]')
        if main_elements.any?
          has_main = true
          main_location = file
          break
        end
      end
      
      warnings = []
      
      # Only report missing main if it's truly missing from the complete page
      unless has_main
        warnings << {
          type: "Page missing MAIN landmark (checked complete page: layout + view + partials)",
          element: {
            tag: 'page',
            text: 'Page-level ARIA landmark check'
          },
          file: @view_file,
          line: 1,
          wcag: "1.3.1",
          remediation: "Add a <main> landmark to your page. It can be in the layout, view, or a partial:\n\n<main id=\"maincontent\">\n  <!-- Page content -->\n</main>",
          page_level_check: true,
          check_type: 'aria_landmarks'
        }
      end
      
      { errors: [], warnings: warnings }
    end

    private

    def create_violation(message:, heading:, wcag_reference:, remediation:)
      {
        message: message,
        file: heading ? heading[:file] : @view_file,
        line: heading ? heading[:line] : 1,
        wcag_reference: wcag_reference,
        remediation: remediation,
        heading: heading  # Keep heading info for element context
      }
    end
  end
end

