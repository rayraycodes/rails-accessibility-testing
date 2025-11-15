# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for proper table structure
    #
    # WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
    #
    # @api private
    class TableStructureCheck < BaseCheck
      def self.rule_name
        :table_structure
      end
      
      def check
        violations = []
        
        page.all('table').each do |table|
          has_headers = table.all('th').any?
          unless has_headers
            element_ctx = element_context(table)
            violations << violation(
              message: "Table missing headers",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: "Add <th> headers to your table:\n\n<table>\n  <thead>\n    <tr><th>Column 1</th></tr>\n  </thead>\n</table>"
            )
          end
        end
        
        violations
      end
    end
  end
end

