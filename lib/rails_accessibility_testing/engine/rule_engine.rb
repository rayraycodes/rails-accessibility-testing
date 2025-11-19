# frozen_string_literal: true

module RailsAccessibilityTesting
  module Engine
    # Core rule engine that evaluates accessibility checks
    #
    # Coordinates check execution, applies configuration, and collects violations.
    #
    # @example
    #   engine = RuleEngine.new(config: config)
    #   violations = engine.check(page)
    #
    # @api private
    class RuleEngine
      attr_reader :config, :violation_collector
      
      # Initialize the rule engine
      # @param config [Hash] Configuration hash from YamlLoader
      def initialize(config:)
        @config = config
        @violation_collector = ViolationCollector.new
        @checks = load_checks
      end
      
      # Run all enabled checks against a page
      # @param page [Capybara::Session] The page to check
      # @param context [Hash] Additional context (url, path, etc.)
      # @param progress_callback [Proc] Optional callback for progress updates
      # @return [Array<Violation>] Array of violations found
      def check(page, context: {}, progress_callback: nil)
        @violation_collector.reset
        
        checks_to_run = enabled_checks.reject { |check_class| rule_ignored?(check_class.rule_name) }
        total_checks = checks_to_run.length
        
        checks_to_run.each_with_index do |check_class, index|
          check_number = index + 1
          check_name = humanize_check_name(check_class.rule_name)
          
          # Report progress
          if progress_callback
            progress_callback.call(check_number, total_checks, check_name, :start)
          end
          
          begin
            check_instance = check_class.new(page: page, context: context)
            violations = check_instance.run
            
            if violations.any?
              @violation_collector.add(violations)
              if progress_callback
                progress_callback.call(check_number, total_checks, check_name, :found_issues, violations.length)
              end
            else
              if progress_callback
                progress_callback.call(check_number, total_checks, check_name, :passed)
              end
            end
          rescue StandardError => e
            # Log but don't fail - one check error shouldn't stop others
            if defined?(RailsAccessibilityTesting) && RailsAccessibilityTesting.config.respond_to?(:logger) && RailsAccessibilityTesting.config.logger
              RailsAccessibilityTesting.config.logger.error("Check #{check_class.rule_name} failed: #{e.message}")
            end
            if progress_callback
              progress_callback.call(check_number, total_checks, check_name, :error, e.message)
            end
          end
        end
        
        @violation_collector.violations
      end
      
      private
      
      # Load all check classes
      def load_checks
        [
          Checks::FormLabelsCheck,
          Checks::ImageAltTextCheck,
          Checks::InteractiveElementsCheck,
          Checks::HeadingCheck,
          Checks::KeyboardAccessibilityCheck,
          Checks::AriaLandmarksCheck,
          Checks::FormErrorsCheck,
          Checks::TableStructureCheck,
          Checks::DuplicateIdsCheck,
          Checks::SkipLinksCheck,
          Checks::ColorContrastCheck
        ]
      end
      
      # Get enabled checks based on configuration
      def enabled_checks
        @checks.select do |check_class|
          check_enabled?(check_class.rule_name)
        end
      end
      
      # Check if a specific check is enabled
      def check_enabled?(rule_name)
        checks_config = @config['checks'] || {}
        check_key = rule_name_to_config_key(rule_name)
        checks_config.fetch(check_key, true) # Default to enabled
      end
      
      # Check if a rule is in the ignored list
      def rule_ignored?(rule_name)
        ignored_rules = @config['ignored_rules'] || []
        ignored_rules.any? { |override| override[:rule] == rule_name || override['rule'] == rule_name }
      end
      
      # Convert rule name to config key
      def rule_name_to_config_key(rule_name)
        rule_name.to_s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end
      
      # Convert rule name to human-readable check name
      def humanize_check_name(rule_name)
        # Map of rule names to friendly display names
        friendly_names = {
          'form_labels' => 'Form Labels',
          'image_alt_text' => 'Image Alt Text',
          'interactive_elements' => 'Interactive Elements',
          'heading' => 'Heading Hierarchy',
          'keyboard_accessibility' => 'Keyboard Accessibility',
          'aria_landmarks' => 'ARIA Landmarks',
          'form_errors' => 'Form Error Associations',
          'table_structure' => 'Table Structure',
          'duplicate_ids' => 'Duplicate IDs',
          'skip_links' => 'Skip Links',
          'color_contrast' => 'Color Contrast'
        }
        
        rule_str = rule_name.to_s
        friendly_names[rule_str] || rule_str.split('_').map(&:capitalize).join(' ')
      end
    end
  end
end

