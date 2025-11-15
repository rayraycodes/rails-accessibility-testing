# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for proper ARIA landmarks
    #
    # WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
    #
    # @api private
    class AriaLandmarksCheck < BaseCheck
      def self.rule_name
        :aria_landmarks
      end
      
      def check
        violations = []
        
        main_landmarks = page.all('main, [role="main"]', visible: true)
        if main_landmarks.empty?
          violations << violation(
            message: "Page missing MAIN landmark",
            element_context: { tag: 'page', text: 'Page has no MAIN landmark' },
            wcag_reference: "1.3.1",
            remediation: "Wrap main content in <main> tag:\n\n<main>\n  <%= yield %>\n</main>"
          )
        end
        
        violations
      end
    end
  end
end

