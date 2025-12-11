# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for duplicate IDs
    #
    # WCAG 2.1 AA: 4.1.1 Parsing (Level A)
    #
    # @note ERB template handling:
    #   - IDs containing "ERB_CONTENT" placeholders are excluded from duplicate checking
    #   - These are dynamic IDs that will have different values at runtime
    #   - Example: "collection_answers_ERB_CONTENT_ERB_CONTENT_" represents a dynamic ID
    #     that will be unique for each checkbox/radio option when rendered
    #   - Static analysis cannot determine if dynamic IDs will be duplicates, so they are skipped
    #
    # @api private
    class DuplicateIdsCheck < BaseCheck
      def self.rule_name
        :duplicate_ids
      end
      
      def check
        violations = []
        # Collect all IDs, filtering out those with ERB_CONTENT placeholders
        # IDs with ERB_CONTENT are dynamic and can't be statically verified for duplicates
        # Example: "collection_answers_ERB_CONTENT_ERB_CONTENT_" - the actual IDs will be different at runtime
        # because the ERB expressions will evaluate to different values
        all_ids = page.all('[id]').map { |el| el[:id] }.compact.reject { |id| id.include?('ERB_CONTENT') }
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

