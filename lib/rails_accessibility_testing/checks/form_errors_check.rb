# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks that form errors are associated with inputs
    #
    # WCAG 2.1 AA: 3.3.1 Error Identification (Level A)
    #
    # @api private
    class FormErrorsCheck < BaseCheck
      def self.rule_name
        :form_errors
      end
      
      def check
        violations = []
        
        page.all('.field_with_errors input, .field_with_errors textarea, .field_with_errors select, .is-invalid, [aria-invalid="true"]').each do |input|
          id = input[:id]
          next if id.blank?
          
          has_error_message = page.has_css?("[aria-describedby*='#{id}'], .field_with_errors label[for='#{id}'] + .error, .field_with_errors label[for='#{id}'] + .invalid-feedback", wait: false)
          
          unless has_error_message
            element_ctx = element_context(input)
            violations << violation(
              message: "Form input error message not associated",
              element_context: element_ctx,
              wcag_reference: "3.3.1",
              remediation: "Associate error message with input using aria-describedby"
            )
          end
        end
        
        violations
      end
    end
  end
end

