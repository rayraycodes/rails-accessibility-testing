# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Comprehensive heading accessibility checks
    #
    # WCAG 2.1 AA requirements for headings:
    # - 1.3.1 Info and Relationships (Level A): Proper heading hierarchy
    # - 2.4.6 Headings and Labels (Level AA): Descriptive headings
    # - 4.1.2 Name, Role, Value (Level A): Headings must have accessible names
    #
    # @api private
    class HeadingCheck < BaseCheck
      def self.rule_name
        :heading
      end
      
      def check
        violations = []
        headings = page.all('h1, h2, h3, h4, h5, h6', visible: true)
        
        if headings.empty?
          return violations  # Warning only, not error
        end
        
        # Check 1: Missing H1 (page-level check - checks complete composed page)
        h1_count = headings.count { |h| h.tag_name == 'h1' }
        first_heading = headings.first
        first_heading_level = first_heading ? first_heading.tag_name[1].to_i : nil
        
        if h1_count == 0
          # If the first heading is h2 or higher, provide a more specific message
          if first_heading_level && first_heading_level >= 2
            element_ctx = element_context(first_heading)
            # Mark as page-level check - H1 might be in layout or partial
            element_ctx[:page_level_check] = true
            element_ctx[:check_type] = 'heading_hierarchy'
            violations << violation(
              message: "Page has h#{first_heading_level} but no h1 heading (checked complete page: layout + view + partials)",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: "Add an <h1> heading to your page. The H1 can be in the layout, view, or a partial:\n\n<h1>Main Page Title</h1>\n<h#{first_heading_level}>#{first_heading.text}</h#{first_heading_level}>"
            )
          else
            violations << violation(
              message: "Page missing H1 heading (checked complete page: layout + view + partials)",
              element_context: { tag: 'page', text: 'Page has no H1 heading', page_level_check: true, check_type: 'heading_hierarchy' },
              wcag_reference: "1.3.1",
              remediation: "Add an <h1> heading to your page. The H1 can be in the layout, view, or a partial:\n\n<h1>Main Page Title</h1>"
            )
          end
        end
        
        # Check 2: Multiple H1s (WCAG 1.3.1) - page-level check
        if h1_count > 1
          # Report error for each h1 after the first one
          h1_elements = headings.select { |h| h.tag_name == 'h1' }
          h1_elements[1..-1].each do |h1|
            element_ctx = element_context(h1)
            element_ctx[:page_level_check] = true
            element_ctx[:check_type] = 'heading_hierarchy'
            violations << violation(
              message: "Page has multiple h1 headings (#{h1_count} total) - only one h1 should be used per page (checked complete page: layout + view + partials)",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: "Use only one <h1> per page. Convert additional h1s to h2 or lower:\n\n<h1>Main Title</h1>\n<h2>Section Title</h2>"
            )
          end
        end
        
        # Check 3: Heading hierarchy skipped levels (WCAG 1.3.1) - page-level check
        previous_level = 0
        headings.each do |heading|
          current_level = heading.tag_name[1].to_i
          if current_level > previous_level + 1
            element_ctx = element_context(heading)
            element_ctx[:page_level_check] = true
            element_ctx[:check_type] = 'heading_hierarchy'
            violations << violation(
              message: "Heading hierarchy skipped (h#{previous_level} to h#{current_level}) - checked complete page: layout + view + partials",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: "Fix the heading hierarchy. Don't skip levels. Use h#{previous_level + 1} instead of h#{current_level}."
            )
          end
          previous_level = current_level
        end
        
        # Check 4: Empty headings (WCAG 4.1.2)
        headings.each do |heading|
          heading_text = heading.text.strip
          
          # Check if heading contains ERB placeholder (for static scanning)
          # ErbExtractor replaces <%= ... %> with "ERB_CONTENT" so we can detect it
          has_erb_content = heading_text.include?('ERB_CONTENT')
          
          # Check if heading is empty or only contains whitespace/formatting
          # Skip if it contains ERB content (will be populated at runtime)
          if (heading_text.empty? || heading_text.match?(/^\s*$/)) && !has_erb_content
            element_ctx = element_context(heading)
            violations << violation(
              message: "Empty heading detected (<#{heading.tag_name}>) - headings must have accessible text",
              element_context: element_ctx,
              wcag_reference: "4.1.2",
              remediation: "Add descriptive text to the heading:\n\n<#{heading.tag_name}>Descriptive Heading Text</#{heading.tag_name}>"
            )
          end
        end
        
        # Check 5: Headings with only images (no alt text or empty alt) (WCAG 4.1.2)
        # Note: For static scanning, we check if heading text is empty
        # Full image checking within headings requires more complex DOM traversal
        # This is a simplified check - full implementation would require xpath queries
        headings.each do |heading|
          heading_text = heading.text.strip
          # If heading has no text, it might be image-only (but we can't easily check images within heading in static mode)
          # This check is primarily for dynamic scanning where we can traverse the DOM
          # For static scanning, we rely on the empty heading check above
        end
        
        # Check 6: Headings used only for styling (WCAG 2.4.6)
        # This is harder to detect automatically, but we can check for very short or generic text
        headings.each do |heading|
          heading_text = heading.text.strip
          # Very short headings (1-2 characters) might be styling-only
          # Generic text like "•", "→", "..." are likely styling
          if heading_text.length <= 2 && heading_text.match?(/^[•→…\s\-_=]+$/)
            element_ctx = element_context(heading)
            violations << violation(
              message: "Heading appears to be used for styling only (text: '#{heading_text}') - headings should be descriptive",
              element_context: element_ctx,
              wcag_reference: "2.4.6",
              remediation: "Use CSS for styling instead of headings. Replace with a <div> or <span> with appropriate CSS classes."
            )
          end
        end
        
        violations
      end
    end
  end
end

