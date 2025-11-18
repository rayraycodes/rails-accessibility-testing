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
        
        page.all('img', visible: :all).each do |img|
          has_alt_attribute = page.evaluate_script("arguments[0].hasAttribute('alt')", img.native)
          # Get alt value - might be nil, empty string, or actual text
          alt_value = img[:alt] || ""
          # Also check via JavaScript to be sure
          alt_value_js = page.evaluate_script("arguments[0].getAttribute('alt')", img.native) || ""
          
          if has_alt_attribute == false
            element_ctx = element_context(img)
            
            violations << violation(
              message: "Image missing alt attribute",
              element_context: element_ctx,
              wcag_reference: "1.1.1",
              remediation: generate_remediation(element_ctx)
            )
          elsif (alt_value.blank? || alt_value_js.blank?) && has_alt_attribute
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

