# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks that form inputs have associated labels
    #
    # WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
    #
    # @note ERB template handling:
    #   - Dynamic IDs with ERB placeholders (e.g., "collection_answers_ERB_CONTENT_ERB_CONTENT_")
    #     are matched against labels with the same ERB structure
    #   - ErbExtractor ensures that IDs and label "for" attributes with matching ERB patterns
    #     will have the same "ERB_CONTENT" placeholder structure, allowing exact matching
    #   - This correctly handles cases like:
    #     <input id="collection_answers_<%= question.id %>_<%= option.id %>_">
    #     <%= label_tag "collection_answers_#{question.id}_#{option.id}_", option.value %>
    #
    # @api private
    class FormLabelsCheck < BaseCheck
      def self.rule_name
        :form_labels
      end
      
      def check
        violations = []
        page_context = self.page_context
        
        # Also check checkbox and radio inputs (they need labels too)
        page.all('input[type="text"], input[type="email"], input[type="password"], input[type="number"], input[type="tel"], input[type="url"], input[type="search"], input[type="date"], input[type="time"], input[type="datetime-local"], input[type="checkbox"], input[type="radio"], textarea, select').each do |input|
          id = input[:id]
          next if id.nil? || id.to_s.strip.empty?
          
          # Skip ERB_CONTENT placeholder - it's not a real ID, just a marker for dynamic content
          next if id == 'ERB_CONTENT'
          
          # Check for label with matching for attribute
          # Handle ERB placeholders in IDs: ErbExtractor preserves the structure of dynamic IDs
          # so "collection_answers_<%= question.id %>_<%= option.id %>_" becomes
          # "collection_answers_ERB_CONTENT_ERB_CONTENT_", and label_tag with the same pattern
          # will also become "collection_answers_ERB_CONTENT_ERB_CONTENT_", so they should match exactly
          has_label = page.has_css?("label[for='#{id}']", wait: false)
          
          aria_label = input[:"aria-label"]
          aria_labelledby = input[:"aria-labelledby"]
          has_aria_label = aria_label && !aria_label.to_s.strip.empty?
          has_aria_labelledby = aria_labelledby && !aria_labelledby.to_s.strip.empty?
          
          unless has_label || has_aria_label || has_aria_labelledby
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

