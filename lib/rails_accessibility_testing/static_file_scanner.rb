# frozen_string_literal: true

require 'nokogiri'
require 'fileutils'

module RailsAccessibilityTesting
  # Static file scanner that scans view files directly without visiting pages
  # Reports errors with exact file locations and line numbers
  class StaticFileScanner
    attr_reader :view_file, :errors, :warnings

    def initialize(view_file)
      @view_file = view_file
      @errors = []
      @warnings = []
      @file_content = nil
      @line_numbers = {}
    end

    # Scan the view file for accessibility issues
    def scan
      return unless File.exist?(@view_file)

      @file_content = File.read(@view_file)
      @line_numbers = build_line_number_map(@file_content)

      # Extract HTML from ERB template
      html_content = extract_html_from_erb(@file_content)

      # Parse HTML with Nokogiri
      doc = Nokogiri::HTML::DocumentFragment.parse(html_content)

      # Run static checks
      check_form_labels(doc)
      check_image_alt_text(doc)
      check_interactive_elements(doc)
      check_heading_hierarchy(doc)
      check_duplicate_ids(doc)
      check_table_structure(doc)

      { errors: @errors, warnings: @warnings }
    end

    private

    # Build a map of HTML content to original line numbers
    def build_line_number_map(content)
      line_map = {}
      lines = content.split("\n")
      current_line = 1

      lines.each_with_index do |line, index|
        # Track which lines contain HTML elements
        if line =~ /<[^%]/
          line_map[index + 1] = line
        end
        current_line += 1
      end

      line_map
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

    # Find the line number for an element in the original file
    def find_line_number(element)
      # Get key attributes to search for
      tag_name = element.name
      id = element['id']
      src = element['src']
      href = element['href']
      type = element['type']
      
      # Search for this element in the original file content
      @file_content.split("\n").each_with_index do |line, index|
        # Must contain the tag name and opening bracket
        next unless line.include?("<#{tag_name}") || line.include?("<#{tag_name.upcase}")
        
        # Try to match by ID first (most specific)
        if id.present? && line.include?("id=") && line.include?(id)
          # Extract ID from line to verify exact match
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
        # (tag name matches and line contains HTML)
        if line.match(/<#{tag_name}[^>]*>/)
          return index + 1
        end
      end

      nil
    end

    # Check form labels
    def check_form_labels(doc)
      inputs = doc.css('input[type="text"], input[type="email"], input[type="password"], input[type="number"], input[type="tel"], input[type="url"], input[type="search"], input[type="date"], input[type="time"], input[type="datetime-local"], textarea, select')

      inputs.each do |input|
        id = input['id']
        next if id.blank?

        # Check for label with matching for attribute
        has_label = doc.css("label[for='#{id}']").any?
        aria_label = input['aria-label'].present?
        aria_labelledby = input['aria-labelledby'].present?

        unless has_label || aria_label || aria_labelledby
          line_num = find_line_number(input)
          @errors << {
            type: 'Form input missing label',
            element: {
              tag: input.name,
              id: id,
              type: input['type'] || input.name,
              html: input.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.3.1'
          }
        end
      end
    end

    # Check image alt text
    def check_image_alt_text(doc)
      images = doc.css('img')

      images.each do |img|
        alt = img['alt']
        has_alt = img.has_attribute?('alt')

        unless has_alt
          line_num = find_line_number(img)
          @errors << {
            type: 'Image missing alt attribute',
            element: {
              tag: 'img',
              src: img['src'],
              html: img.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.1.1'
          }
        elsif alt.blank? && has_alt
          # Empty alt is valid for decorative images, but warn
          line_num = find_line_number(img)
          @warnings << {
            type: 'Image has empty alt attribute',
            element: {
              tag: 'img',
              src: img['src'],
              html: img.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.1.1'
          }
        end
      end
    end

    # Check interactive elements have accessible names
    def check_interactive_elements(doc)
      # Check buttons
      buttons = doc.css('button')
      buttons.each do |button|
        text = button.text.strip
        aria_label = button['aria-label']
        aria_labelledby = button['aria-labelledby']
        title = button['title']

        if text.blank? && aria_label.blank? && aria_labelledby.blank? && title.blank?
          line_num = find_line_number(button)
          @errors << {
            type: 'Button missing accessible name',
            element: {
              tag: 'button',
              id: button['id'],
              html: button.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '4.1.2'
          }
        end
      end

      # Check links
      links = doc.css('a[href]')
      links.each do |link|
        text = link.text.strip
        aria_label = link['aria-label']
        aria_labelledby = link['aria-labelledby']
        title = link['title']
        img_alt = link.css('img').first&.[]('alt')

        if text.blank? && aria_label.blank? && aria_labelledby.blank? && title.blank? && img_alt.blank?
          line_num = find_line_number(link)
          @errors << {
            type: 'Link missing accessible name',
            element: {
              tag: 'a',
              href: link['href'],
              html: link.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '4.1.2'
          }
        end
      end
    end

    # Check heading hierarchy
    def check_heading_hierarchy(doc)
      headings = doc.css('h1, h2, h3, h4, h5, h6').to_a
      return if headings.empty?

      # Check for multiple h1s
      h1s = headings.select { |h| h.name == 'h1' }
      if h1s.length > 1
        h1s.each do |h1|
          line_num = find_line_number(h1)
          @errors << {
            type: 'Multiple h1 headings found',
            element: {
              tag: 'h1',
              text: h1.text.strip,
              html: h1.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.3.1'
          }
        end
      end

      # Check for skipped heading levels
      previous_level = 0
      headings.each do |heading|
        current_level = heading.name[1].to_i
        if previous_level > 0 && current_level > previous_level + 1
          line_num = find_line_number(heading)
          @errors << {
            type: "Heading level skipped (h#{previous_level} to h#{current_level})",
            element: {
              tag: heading.name,
              text: heading.text.strip,
              html: heading.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.3.1'
          }
        end
        previous_level = current_level
      end
    end

    # Check for duplicate IDs
    def check_duplicate_ids(doc)
      ids = {}
      doc.css('[id]').each do |element|
        id = element['id']
        next if id.blank?

        if ids[id]
          ids[id] << element
        else
          ids[id] = [element]
        end
      end

      ids.each do |id, elements|
        next if elements.length == 1

        elements.each do |element|
          line_num = find_line_number(element)
          @errors << {
            type: "Duplicate ID: #{id}",
            element: {
              tag: element.name,
              id: id,
              html: element.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '4.1.1'
          }
        end
      end
    end

    # Check table structure
    def check_table_structure(doc)
      tables = doc.css('table')

      tables.each do |table|
        # Check for headers
        headers = table.css('th')
        if headers.empty?
          line_num = find_line_number(table)
          @errors << {
            type: 'Table missing header cells (th)',
            element: {
              tag: 'table',
              html: table.to_html
            },
            file: @view_file,
            line: line_num,
            wcag: '1.3.1'
          }
        end

        # Check for scope attributes on th elements
        headers.each do |th|
          scope = th['scope']
          if scope.blank?
            line_num = find_line_number(th)
            @warnings << {
              type: 'Table header missing scope attribute',
              element: {
                tag: 'th',
                html: th.to_html
              },
              file: @view_file,
              line: line_num,
              wcag: '1.3.1'
            }
          end
        end
      end
    end
  end
end

