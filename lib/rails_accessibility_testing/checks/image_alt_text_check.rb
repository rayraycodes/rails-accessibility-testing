# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks that images have alt attributes
    #
    # WCAG 2.1 AA: 1.1.1 Non-text Content (Level A)
    #
    # @api private
    class ImageAltTextCheck < BaseCheck
      def self.rule_name
        :image_alt_text
      end
      
      def check
        violations = []
        
        # Use native attribute access instead of JavaScript evaluation for better performance
        page.all('img', visible: :all).each do |img|
          # Get alt value directly from Capybara element (faster than JavaScript)
          alt_value = img[:alt]
          # Check if alt attribute exists (nil means missing, empty string means present but empty)
          has_alt_attribute = img.native.attribute('alt') != nil rescue false
          
          if !has_alt_attribute
            element_ctx = element_context(img)
            
            violations << violation(
              message: "Image missing alt attribute",
              element_context: element_ctx,
              wcag_reference: "1.1.1",
              remediation: generate_remediation(element_ctx)
            )
          elsif (alt_value.nil? || alt_value.to_s.strip.empty?) && has_alt_attribute
            # Image has alt attribute but it's empty - warn about this
            # Empty alt is valid for decorative images, but we should check if it's actually decorative
            element_ctx = element_context(img)
            
            violations << violation(
              message: "Image has empty alt attribute - ensure this image is purely decorative. If it conveys information, add descriptive alt text.",
              element_context: element_ctx,
              wcag_reference: "1.1.1",
              remediation: generate_remediation(element_ctx)
            )
          end
        end
        
        violations
      end
      
      private
      
      def generate_remediation(element_context)
        src = element_context[:src] || 'image.png'
        
        "Choose ONE of these solutions:\n\n" \
        "1. Add alt text for informative images:\n" \
        "   <img src=\"#{src}\" alt=\"Description of image\">\n\n" \
        "2. Add empty alt for decorative images:\n" \
        "   <img src=\"#{src}\" alt=\"\">\n\n" \
        "3. Use Rails image_tag helper:\n" \
        "   <%= image_tag 'image.png', alt: 'Description' %>"
      end
    end
  end
end

