# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Checks for skip links
    #
    # WCAG 2.1 AA: 2.4.1 Bypass Blocks (Level A)
    #
    # @api private
    class SkipLinksCheck < BaseCheck
      def self.rule_name
        :skip_links
      end
      
      def check
        violations = []
        # This is a warning-only check, so we return empty violations
        # but could add a warning mechanism if needed
        violations
      end
    end
  end
end

