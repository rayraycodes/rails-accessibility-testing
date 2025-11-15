# frozen_string_literal: true

module RailsAccessibilityTesting
  module Engine
    # Represents a single accessibility violation
    #
    # Contains all information needed to understand and fix the issue.
    #
    # @example
    #   violation = Violation.new(
    #     rule_name: 'form_labels',
    #     message: 'Form input missing label',
    #     element: element,
    #     page_context: { url: '/', path: '/' }
    #   )
    #
    # @api private
    class Violation
      attr_reader :rule_name, :message, :element_context, :page_context, :wcag_reference, :remediation
      
      # Initialize a violation
      # @param rule_name [String, Symbol] Name of the rule that was violated
      # @param message [String] Human-readable error message
      # @param element_context [Hash] Context about the element with the issue
      # @param page_context [Hash] Context about the page being tested
      # @param wcag_reference [String] WCAG reference (e.g., "1.1.1")
      # @param remediation [String] Suggested fix
      def initialize(rule_name:, message:, element_context: {}, page_context: {}, wcag_reference: nil, remediation: nil)
        @rule_name = rule_name.to_s
        @message = message
        @element_context = element_context
        @page_context = page_context
        @wcag_reference = wcag_reference
        @remediation = remediation
      end
      
      # Convert to hash for JSON serialization
      # @return [Hash]
      def to_h
        {
          rule_name: @rule_name,
          message: @message,
          element_context: @element_context,
          page_context: @page_context,
          wcag_reference: @wcag_reference,
          remediation: @remediation
        }
      end
      
      # Convert to JSON string
      # @return [String]
      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end

