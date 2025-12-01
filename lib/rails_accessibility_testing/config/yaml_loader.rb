# frozen_string_literal: true

require 'yaml'

module RailsAccessibilityTesting
  module Config
    # Loads and parses the accessibility.yml configuration file
    #
    # Supports profiles (development, test, ci) and rule overrides.
    #
    # @example Configuration file structure
    #   # config/accessibility.yml
    #   wcag_level: AA
    #   
    #   development:
    #     checks:
    #       color_contrast: false  # Skip in dev for speed
    #   
    #   ci:
    #     checks:
    #       color_contrast: true   # Full checks in CI
    #
    # @api private
    class YamlLoader
      DEFAULT_CONFIG_PATH = 'config/accessibility.yml'
      
      class << self
        # Load configuration from YAML file
        # @param path [String] Path to config file
        # @param profile [Symbol] Profile to use (:development, :test, :ci)
        # @return [Hash] Configuration hash
        def load(path: DEFAULT_CONFIG_PATH, profile: :test)
          config_path = resolve_config_path(path)
          return default_config unless config_path && File.exist?(config_path)
          
          yaml_content = File.read(config_path)
          parsed = YAML.safe_load(yaml_content, permitted_classes: [Symbol], aliases: true) || {}
          
          merge_profile_config(parsed, profile)
        rescue StandardError => e
          if defined?(RailsAccessibilityTesting) && RailsAccessibilityTesting.config.respond_to?(:logger) && RailsAccessibilityTesting.config.logger
            RailsAccessibilityTesting.config.logger.warn("Failed to load config: #{e.message}")
          end
          default_config
        end
        
        private
        
        # Resolve config path relative to Rails root
        def resolve_config_path(path)
          return path if Pathname.new(path).absolute?
          
          if defined?(Rails) && Rails.root
            Rails.root.join(path).to_s
          else
            path
          end
        end
        
        # Merge profile-specific config with base config
        def merge_profile_config(parsed, profile)
          base_config = parsed.reject { |k, _| k.to_s.match?(/^(development|test|ci)$/) }
          profile_config = parsed[profile.to_s] || parsed[profile] || {}
          
          # Deep merge checks configuration
          checks = base_config['checks'] || {}
          profile_checks = profile_config['checks'] || {}
          
          merged_checks = checks.merge(profile_checks)
          
          # Deep merge summary configuration
          base_summary = base_config['summary'] || {}
          profile_summary = profile_config['summary'] || {}
          merged_summary = base_summary.merge(profile_summary)
          
          # Merge static_scanner config
          base_static_scanner = base_config['static_scanner'] || {}
          profile_static_scanner = profile_config['static_scanner'] || {}
          merged_static_scanner = base_static_scanner.merge(profile_static_scanner)
          
          # Merge system_specs config
          base_system_specs = base_config['system_specs'] || {}
          profile_system_specs = profile_config['system_specs'] || {}
          merged_system_specs = base_system_specs.merge(profile_system_specs)
          
          base_config.merge(
            'enabled' => profile_config.fetch('enabled', base_config.fetch('enabled', true)),  # Profile can override enabled, default to true
            'checks' => merged_checks,
            'summary' => merged_summary,
            'scan_strategy' => profile_config['scan_strategy'] || base_config['scan_strategy'] || 'paths',
            'static_scanner' => merged_static_scanner,
            'system_specs' => merged_system_specs,
            'profile' => profile.to_s,
            'ignored_rules' => parse_ignored_rules(parsed, profile)
          )
        end
        
        # Parse ignored rules with comments
        def parse_ignored_rules(parsed, profile)
          ignored = []
          
          # Check base config
          ignored.concat(parse_rule_overrides(parsed['ignored_rules'] || []))
          
          # Check profile-specific ignored rules
          profile_config = parsed[profile.to_s] || parsed[profile] || {}
          ignored.concat(parse_rule_overrides(profile_config['ignored_rules'] || []))
          
          ignored.uniq
        end
        
        # Parse rule override entries
        def parse_rule_overrides(overrides)
          overrides.map do |override|
            {
              rule: override['rule'] || override[:rule],
              reason: override['reason'] || override[:reason] || 'No reason provided',
              comment: override['comment'] || override[:comment]
            }
          end.compact
        end
        
        # Default configuration when no file exists
        def default_config
          {
            'enabled' => true,  # Global enable/disable flag for all accessibility checks
            'wcag_level' => 'AA',
            'checks' => default_checks,
            'summary' => {
              'show_summary' => true,
              'errors_only' => false,
              'show_fixes' => true,
              'ignore_warnings' => false
            },
            'scan_strategy' => 'paths',
            'system_specs' => {
              'auto_run' => false  # Run accessibility checks automatically in system specs (default: false)
            },
            'ignored_rules' => [],
            'profile' => 'test'
          }
        end
        
        # Default check configuration (all enabled)
        def default_checks
          {
            'form_labels' => true,
            'image_alt_text' => true,
            'interactive_elements' => true,
            'heading' => true,
            'keyboard_accessibility' => true,
            'aria_landmarks' => true,
            'form_errors' => true,
            'table_structure' => true,
            'duplicate_ids' => true,
            'skip_links' => true,
            'color_contrast' => false  # Disabled by default (expensive)
          }
        end
      end
    end
  end
end

