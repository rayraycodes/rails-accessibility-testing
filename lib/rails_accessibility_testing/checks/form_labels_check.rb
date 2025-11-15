# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks that form inputs have associated labels
    #
    # WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
    #
    # @api private
    class FormLabelsCheck < BaseCheck
      def self.rule_name
        :form_labels
      end
      
      def check
        violations = []
        page_context = self.page_context
        
        page.all('input[type="text"], input[type="email"], input[type="password"], input[type="number"], input[type="tel"], input[type="url"], input[type="search"], input[type="date"], input[type="time"], input[type="datetime-local"], textarea, select').each do |input|
          id = input[:id]
          next if id.blank?
          
          has_label = page.has_css?("label[for='#{id}']", wait: false)
          aria_label = input[:"aria-label"].present?
          aria_labelledby = input[:"aria-labelledby"].present?
          
          unless has_label || aria_label || aria_labelledby
            element_ctx = element_context(input)
            element_ctx[:input_type] = input[:type] || input.tag_name
            
            violations << violation(
              message: "Form input missing label",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: generate_remediation(element_ctx)
            )
          end
        end
        
        violations
      end
      
      private
      
      def generate_remediation(element_context)
        id = element_context[:id]
        input_type = element_context[:input_type] || 'text'
        
        "Choose ONE of these solutions:\n\n" \
        "1. Add a <label> element:\n" \
        "   <label for=\"#{id}\">Field Label</label>\n" \
        "   <input type=\"#{input_type}\" id=\"#{id}\" name=\"field_name\">\n\n" \
        "2. Add aria-label attribute:\n" \
        "   <input type=\"#{input_type}\" id=\"#{id}\" aria-label=\"Field Label\">\n\n" \
        "3. Use Rails helper:\n" \
        "   <%= form.label :field_name, 'Field Label' %>\n" \
        "   <%= form.text_field :field_name, id: '#{id}' %>"
      end
    end
  end
end

