# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks that interactive elements have accessible names
    #
    # WCAG 2.1 AA: 2.4.4 Link Purpose (Level A), 4.1.2 Name, Role, Value (Level A)
    #
    # @api private
    class InteractiveElementsCheck < BaseCheck
      def self.rule_name
        :interactive_elements
      end
      
      def check
        violations = []
        
        page.all('button, a[href], [role="button"], [role="link"]').each do |element|
          next unless element.visible?
          
          # Check for headings inside button elements (accessibility violation)
          # Headings should not be nested inside interactive elements
          if element.tag_name == 'button' || element[:role] == 'button'
            headings_inside = element.all('h1, h2, h3, h4, h5, h6', visible: true)
            if headings_inside.any?
              headings_inside.each do |heading|
                element_ctx = element_context(element)
                heading_level = heading.tag_name
                element_ctx[:nested_heading] = heading_level
                element_ctx[:heading_text] = heading.text.strip
                
                violations << violation(
                  message: "Button contains #{heading_level.upcase} heading - headings should not be nested inside buttons",
                  element_context: element_ctx,
                  wcag_reference: "4.1.2",
                  remediation: "Remove the heading from inside the button. Use plain text or aria-label instead:\n\n" \
                               "<button aria-label='#{heading.text.strip}'>#{heading.text.strip}</button>\n\n" \
                               "Or use a div/span with appropriate styling instead of a heading element."
                )
              end
            end
          end
          
          text = element.text.to_s.strip
          aria_label = element[:"aria-label"]
          aria_labelledby = element[:"aria-labelledby"]
          title = element[:title]
          
          # Check if element contains ERB placeholder (for static scanning)
          # ErbExtractor replaces <%= ... %> with "ERB_CONTENT" so we can detect it
          # If text includes "ERB_CONTENT", it means there's ERB code that will produce content at runtime
          has_erb_content = text.include?('ERB_CONTENT')
          
          # Check if element contains an image with alt text (common pattern for logo links)
          has_image_with_alt = false
          if text.empty? && !has_erb_content
            # For static scanning, we can't easily check images within elements
            # This check works better in dynamic scanning with Capybara
            # For now, skip image checking in static mode
            has_image_with_alt = false
          end
          
          # Text is empty only if it's actually empty AND doesn't contain ERB content
          # If it contains ERB_CONTENT, it will have content at runtime, so it's not empty
          text_empty = text.empty? && !has_erb_content
          
          aria_label_empty = aria_label.nil? || aria_label.to_s.strip.empty?
          aria_labelledby_empty = aria_labelledby.nil? || aria_labelledby.to_s.strip.empty?
          title_empty = title.nil? || title.to_s.strip.empty?
          
          if text_empty && aria_label_empty && aria_labelledby_empty && title_empty && !has_image_with_alt
            element_ctx = element_context(element)
            tag = element.tag_name
            
            violations << violation(
              message: "#{tag.capitalize} missing accessible name",
              element_context: element_ctx,
              wcag_reference: tag == 'a' ? "2.4.4" : "4.1.2",
              remediation: generate_remediation(tag, element_ctx)
            )
          end
        end
        
        violations
      end
      
      private
      
      def generate_remediation(tag, element_context)
        if tag == 'a'
          "Choose ONE of these solutions:\n\n" \
          "1. Add visible link text:\n" \
          "   <%= link_to 'Descriptive Link Text', path %>\n\n" \
          "2. Add aria-label (for icon-only links):\n" \
          "   <%= link_to path, aria: { label: 'Descriptive action' } do %>\n" \
          "     <i class='icon'></i>\n" \
          "   <% end %>"
        else
          "Choose ONE of these solutions:\n\n" \
          "1. Add visible button text:\n" \
          "   <button>Descriptive Button Text</button>\n\n" \
          "2. Add aria-label (for icon-only buttons):\n" \
          "   <button aria-label='Descriptive action'>\n" \
          "     <i class='icon'></i>\n" \
          "   </button>"
        end
      end
    end
  end
end

