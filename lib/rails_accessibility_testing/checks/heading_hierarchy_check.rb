# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for proper heading hierarchy
    #
    # WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
    #
    # @api private
    class HeadingHierarchyCheck < BaseCheck
      def self.rule_name
        :heading_hierarchy
      end
      
      def check
        violations = []
        headings = page.all('h1, h2, h3, h4, h5, h6', visible: true)
        
        if headings.empty?
          return violations  # Warning only, not error
        end
        
        h1_count = headings.count { |h| h.tag_name == 'h1' }
        if h1_count == 0
          violations << violation(
            message: "Page missing H1 heading",
            element_context: { tag: 'page', text: 'Page has no H1 heading' },
            wcag_reference: "1.3.1",
            remediation: "Add an <h1> heading to your page:\n\n<h1>Main Page Title</h1>"
          )
        end
        
        previous_level = 0
        headings.each do |heading|
          current_level = heading.tag_name[1].to_i
          if current_level > previous_level + 1
            element_ctx = element_context(heading)
            violations << violation(
              message: "Heading hierarchy skipped (h#{previous_level} to h#{current_level})",
              element_context: element_ctx,
              wcag_reference: "1.3.1",
              remediation: "Fix the heading hierarchy. Don't skip levels."
            )
          end
          previous_level = current_level
        end
        
        violations
      end
    end
  end
end

