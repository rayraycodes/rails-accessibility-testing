# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for duplicate IDs
    #
    # WCAG 2.1 AA: 4.1.1 Parsing (Level A)
    #
    # @api private
    class DuplicateIdsCheck < BaseCheck
      def self.rule_name
        :duplicate_ids
      end
      
      def check
        violations = []
        all_ids = page.all('[id]').map { |el| el[:id] }.compact
        duplicates = all_ids.group_by(&:itself).select { |_k, v| v.length > 1 }.keys
        
        if duplicates.any?
          first_duplicate_id = duplicates.first
          first_element = page.first("[id='#{first_duplicate_id}']", wait: false)
          
          element_ctx = if first_element
            ctx = element_context(first_element)
            ctx[:duplicate_ids] = duplicates
            ctx
          else
            {
              tag: 'multiple',
              id: first_duplicate_id,
              duplicate_ids: duplicates
            }
          end
          
          violations << violation(
            message: "Duplicate IDs found: #{duplicates.join(', ')}",
            element_context: element_ctx,
            wcag_reference: "4.1.1",
            remediation: "Ensure each ID is unique on the page"
          )
        end
        
        violations
      end
    end
  end
end

