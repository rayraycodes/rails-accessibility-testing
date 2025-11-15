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
      # @return [Array<Violation>] Array of violations found
      def check(page, context: {})
        @violation_collector.reset
        
        enabled_checks.each do |check_class|
          next if rule_ignored?(check_class.rule_name)
          
          begin
            check_instance = check_class.new(page: page, context: context)
            violations = check_instance.run
            @violation_collector.add(violations) if violations.any?
          rescue StandardError => e
            # Log but don't fail - one check error shouldn't stop others
            RailsAccessibilityTesting.config.logger&.error("Check #{check_class.rule_name} failed: #{e.message}") if defined?(RailsAccessibilityTesting)
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
          Checks::HeadingHierarchyCheck,
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
    end
  end
end

