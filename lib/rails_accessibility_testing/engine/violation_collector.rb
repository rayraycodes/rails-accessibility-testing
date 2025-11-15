# frozen_string_literal: true

module RailsAccessibilityTesting
  module Engine
    # Collects and manages accessibility violations
    #
    # Aggregates violations from multiple checks and provides
    # summary statistics and formatted output.
    #
    # @api private
    class ViolationCollector
      attr_reader :violations
      
      def initialize
        @violations = []
      end
      
      # Add violations to the collection
      # @param new_violations [Array<Violation>] Violations to add
      def add(new_violations)
        @violations.concat(Array(new_violations))
      end
      
      # Reset the collection
      def reset
        @violations = []
      end
      
      # Check if any violations exist
      # @return [Boolean]
      def any?
        @violations.any?
      end
      
      # Get count of violations
      # @return [Integer]
      def count
        @violations.count
      end
      
      # Get violations grouped by rule
      # @return [Hash<String, Array<Violation>>]
      def grouped_by_rule
        @violations.group_by(&:rule_name)
      end
      
      # Get summary statistics
      # @return [Hash]
      def summary
        {
          total: count,
          by_rule: grouped_by_rule.transform_values(&:count),
          rules_affected: grouped_by_rule.keys.count
        }
      end
    end
  end
end

