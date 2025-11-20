# frozen_string_literal: true

# Static scanning module - provides file-based accessibility scanning
# This module aggregates all static scanning components for easy access
#
# @api public
module RailsAccessibilityTesting
  # Static scanning components
  # All components work together to scan view files without browser rendering
  #
  # Components:
  # - StaticFileScanner: Main scanner that orchestrates the scanning process
  # - ErbExtractor: Converts ERB templates to HTML for analysis
  # - StaticPageAdapter: Makes Nokogiri documents look like Capybara pages
  # - LineNumberFinder: Finds line numbers for reported issues
  # - ViolationConverter: Converts violations to error/warning format
  #
  # All 11 accessibility checks are automatically used via RuleEngine:
  # 1. FormLabelsCheck
  # 2. ImageAltTextCheck
  # 3. InteractiveElementsCheck
  # 4. HeadingCheck
  # 5. KeyboardAccessibilityCheck
  # 6. AriaLandmarksCheck
  # 7. FormErrorsCheck
  # 8. TableStructureCheck
  # 9. DuplicateIdsCheck
  # 10. SkipLinksCheck
  # 11. ColorContrastCheck
  #
  # @example Scanning a view file
  #   scanner = StaticFileScanner.new('app/views/pages/home.html.erb')
  #   result = scanner.scan
  #   # => { errors: [...], warnings: [...] }
  #
  module StaticScanning
    # Convenience method to scan a single file
    # @param file_path [String] Path to view file
    # @return [Hash] Hash with :errors and :warnings arrays
    def self.scan_file(file_path)
      StaticFileScanner.new(file_path).scan
    end

    # Convenience method to scan multiple files
    # @param file_paths [Array<String>] Array of file paths
    # @return [Hash] Hash with :errors and :warnings arrays (aggregated)
    def self.scan_files(file_paths)
      all_errors = []
      all_warnings = []

      file_paths.each do |file_path|
        result = scan_file(file_path)
        all_errors.concat(result[:errors] || [])
        all_warnings.concat(result[:warnings] || [])
      end

      { errors: all_errors, warnings: all_warnings }
    end
  end
end

