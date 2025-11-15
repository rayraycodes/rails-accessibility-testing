# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks keyboard accessibility for modals
    #
    # WCAG 2.1 AA: 2.1.1 Keyboard (Level A)
    #
    # @api private
    class KeyboardAccessibilityCheck < BaseCheck
      def self.rule_name
        :keyboard_accessibility
      end
      
      def check
        violations = []
        
        page.all('[role="dialog"], [role="alertdialog"]', visible: true).each do |modal|
          focusable = modal.all('button, a, input, textarea, select, [tabindex]:not([tabindex="-1"])', visible: true)
          if focusable.empty?
            element_ctx = element_context(modal)
            violations << violation(
              message: "Modal dialog has no focusable elements",
              element_context: element_ctx,
              wcag_reference: "2.1.1",
              remediation: "Add focusable elements to the modal (buttons, links, inputs)"
            )
          end
        end
        
        violations
      end
    end
  end
end

