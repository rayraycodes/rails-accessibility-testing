# frozen_string_literal: true

module RailsAccessibilityTesting
  # Converts Violation objects to error/warning hash format
  # Used by static file scanner to format results
  #
  # @api private
  class ViolationConverter
    # Convert violations to errors/warnings format
    # @param violations [Array<Engine::Violation>] Array of violations
    # @param view_file [String] Path to the view file
    # @param line_number_finder [LineNumberFinder] Finder for line numbers
    # @param config [Hash] Optional configuration hash (for ignore_warnings flag)
    # @return [Hash] Hash with :errors and :warnings arrays
    def self.convert(violations, view_file:, line_number_finder:, config: {})
      new(violations, view_file: view_file, line_number_finder: line_number_finder, config: config).convert
    end

    def initialize(violations, view_file:, line_number_finder:, config: {})
      @violations = violations
      @view_file = view_file
      @line_number_finder = line_number_finder
      @config = config
    end

    def convert
      errors = []
      warnings = []

      @violations.each do |violation|
        # Skip warnings if ignore_warnings is enabled
        if warning?(violation) && ignore_warnings?
          next
        end

        element_context = violation.element_context || {}
        line_num = @line_number_finder.find_line_number(element_context)

        error_data = {
          type: violation.message,
          element: element_context,
          file: @view_file,
          line: line_num,
          wcag: violation.wcag_reference
        }

        if warning?(violation)
          warnings << error_data
        else
          errors << error_data
        end
      end

      { errors: errors, warnings: warnings }
    end

    private

    # Check if warnings should be ignored
    def ignore_warnings?
      summary_config = @config['summary'] || {}
      summary_config.fetch('ignore_warnings', false)
    end

    # Determine if a violation should be a warning instead of an error
    def warning?(violation)
      message = violation.message
      rule_name = violation.rule_name

      # Skip links are warnings (best practice, not required)
      return true if message.include?('skip link') || message.include?('Skip link')

      # ARIA landmarks are warnings (best practice, not always required)
      return true if rule_name == 'aria_landmarks'

      false
    end
  end
end

