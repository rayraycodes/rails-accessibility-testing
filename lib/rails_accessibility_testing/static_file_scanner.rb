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
      
      # Check if accessibility checks are globally disabled
      begin
        config = Config::YamlLoader.load(profile: :test)
        # Support both 'accessibility_enabled' (new) and 'enabled' (legacy) for backward compatibility
        enabled = config.fetch('accessibility_enabled', config.fetch('enabled', true))
        return { errors: [], warnings: [] } unless enabled
      rescue StandardError
        # If config can't be loaded, continue (assume enabled)
      end

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

        # For page-level checks, use composed page scanner
        # This checks the complete page (layout + view + partials) for:
        # - All heading checks (hierarchy, empty, styling-only)
        # - ARIA landmarks (main, etc.)
        # - Duplicate IDs (must be unique across entire page)
        require_relative 'composed_page_scanner'
        composed_scanner = ComposedPageScanner.new(@view_file)
        hierarchy_result = composed_scanner.scan_heading_hierarchy
        all_headings_result = composed_scanner.scan_all_headings
        landmarks_result = composed_scanner.scan_aria_landmarks
        duplicate_ids_result = composed_scanner.scan_duplicate_ids
        
        # Filter out page-level violations from regular violations
        # (we'll use the composed page scanner results instead)
        heading_violations = violations.select { |v| 
          v.rule_name.to_s == 'heading'
        }
        landmarks_violations = violations.select { |v| 
          v.rule_name.to_s == 'aria_landmarks' &&
          (v.message.include?('missing MAIN') || v.message.include?('missing main') || 
           v.message.include?('MAIN landmark')) 
        }
        duplicate_ids_violations = violations.select { |v|
          v.rule_name.to_s == 'duplicate_ids'
        }
        other_violations = violations.reject { |v| 
          heading_violations.include?(v) || landmarks_violations.include?(v) || duplicate_ids_violations.include?(v)
        }
        
        # Convert non-page-level violations to errors/warnings format
        line_number_finder = LineNumberFinder.new(@file_content)
        result = ViolationConverter.convert(
          other_violations,
          view_file: @view_file,
          line_number_finder: line_number_finder,
          config: config
        )
        
        # Add composed page results (all heading checks + landmarks + duplicate IDs)
        result[:errors] = (result[:errors] || []) + 
                         hierarchy_result[:errors] + 
                         all_headings_result[:errors] + 
                         duplicate_ids_result[:errors]
        result[:warnings] = (result[:warnings] || []) + 
                          hierarchy_result[:warnings] + 
                          all_headings_result[:warnings] + 
                          landmarks_result[:warnings] + 
                          duplicate_ids_result[:warnings]
        
        result
      rescue StandardError => e
        # If engine fails, log error and return empty results
        if defined?(Rails) && Rails.env.development?
          puts "Error in static scanner: #{e.message}"
          puts e.backtrace.first(3).join("\n")
        end
        { errors: [], warnings: [] }
      end
    end
  end
end

