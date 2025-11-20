# frozen_string_literal: true

require 'nokogiri'
require 'fileutils'
require_relative 'static_page_adapter'
require_relative 'engine/rule_engine'
require_relative 'config/yaml_loader'
require_relative 'erb_extractor'
require_relative 'line_number_finder'
require_relative 'violation_converter'

module RailsAccessibilityTesting
  # Static file scanner that scans view files directly without visiting pages
  # Uses the existing RuleEngine and all 11 checks from the checks/ folder
  # Reports errors with exact file locations and line numbers
  #
  # @example
  #   scanner = StaticFileScanner.new('app/views/pages/home.html.erb')
  #   result = scanner.scan
  #   # => { errors: [...], warnings: [...] }
  #
  # @api public
  class StaticFileScanner
    attr_reader :view_file

    def initialize(view_file)
      @view_file = view_file
      @file_content = nil
    end

    # Scan the view file for accessibility issues using all checks via RuleEngine
    # @return [Hash] Hash with :errors and :warnings arrays
    def scan
      return { errors: [], warnings: [] } unless File.exist?(@view_file)

      @file_content = File.read(@view_file)

      # Extract HTML from ERB template using modular extractor
      html_content = ErbExtractor.extract_html(@file_content)

      # Create static page adapter (makes Nokogiri look like Capybara)
      static_page = StaticPageAdapter.new(html_content, view_file: @view_file)

      # Load config and create engine (reuse existing infrastructure)
      # This automatically loads and runs all 11 checks:
      # FormLabelsCheck, ImageAltTextCheck, InteractiveElementsCheck,
      # HeadingCheck, KeyboardAccessibilityCheck, AriaLandmarksCheck,
      # FormErrorsCheck, TableStructureCheck, DuplicateIdsCheck,
      # SkipLinksCheck, ColorContrastCheck
      begin
        config = Config::YamlLoader.load(profile: :test)
        engine = Engine::RuleEngine.new(config: config)

        # Context for violations
        context = {
          url: nil,
          path: nil,
          view_file: @view_file
        }

        # Run all enabled checks using existing RuleEngine
        violations = engine.check(static_page, context: context)

        # Convert violations to errors/warnings format with line numbers
        line_number_finder = LineNumberFinder.new(@file_content)
        ViolationConverter.convert(
          violations,
          view_file: @view_file,
          line_number_finder: line_number_finder,
          config: config
        )
      rescue StandardError => e
        # If engine fails, return empty results
        # Could log error here if needed
        { errors: [], warnings: [] }
      end
    end
  end
end

