# frozen_string_literal: true

module RailsAccessibilityTesting
  # RSpec integration and auto-configuration
  class RSpecIntegration
    class << self
      # Configure RSpec for accessibility testing
      def configure!(config)
        enable_spec_type_inference(config)
        include_matchers(config)
        include_helpers(config)
        
        # Check YAML config first, then fall back to initializer config
        auto_run = should_auto_run_checks?
        setup_automatic_checks(config) if auto_run
      end
      
      # Determine if checks should run automatically
      # Checks YAML config first, then falls back to initializer config
      # 
      # Priority:
      # 1. YAML config: system_specs.auto_run (if explicitly set)
      # 2. Initializer config: config.auto_run_checks (fallback)
      def should_auto_run_checks?
        # Try to load from YAML config
        begin
          require 'rails_accessibility_testing/config/yaml_loader'
          profile = defined?(Rails) && Rails.env.test? ? :test : :development
          yaml_config = Config::YamlLoader.load(profile: profile)
          
          # Check if system_specs.auto_run is explicitly set in YAML
          # Use key? to distinguish between nil/not-set vs explicitly false
          if yaml_config['system_specs'] && yaml_config['system_specs'].key?('auto_run')
            auto_run_value = yaml_config['system_specs']['auto_run']
            # Return the value (true or false) - explicitly set in YAML
            return auto_run_value
          end
        rescue StandardError => e
          # If YAML loading fails, fall through to initializer config
          # Could log error here if needed for debugging
        end
        
        # Fall back to initializer configuration (default: true)
        RailsAccessibilityTesting.config.auto_run_checks
      end

      private

      # Check if accessibility checks are globally disabled via config
      def accessibility_globally_disabled?
        begin
          require 'rails_accessibility_testing/config/yaml_loader'
          profile = defined?(Rails) && Rails.env.test? ? :test : :development
          config = Config::YamlLoader.load(profile: profile)
          enabled = config.fetch('enabled', true)  # Default to enabled if not specified
          !enabled  # Return true if disabled
        rescue StandardError
          false  # If config can't be loaded, assume enabled
        end
      end

      # Enable automatic spec type inference from file location
      def enable_spec_type_inference(config)
        # Only call if the method exists (requires rspec-rails to be loaded)
        config.infer_spec_type_from_file_location! if config.respond_to?(:infer_spec_type_from_file_location!)
      end

      # Include Axe matchers for system specs
      def include_matchers(config)
        config.include Axe::Matchers, type: :system
      end

      # Include accessibility helpers for system specs
      def include_helpers(config)
        config.include RailsAccessibilityTesting::AccessibilityHelper, type: :system
      end

      # Setup automatic accessibility checks
      def setup_automatic_checks(config)
        # Check if accessibility checks are globally disabled
        return if accessibility_globally_disabled?
        
        # Use class variable to track results across all examples
        @@accessibility_results = {
          pages_tested: [],
          total_errors: 0,
          total_warnings: 0,
          pages_passed: 0,
          pages_failed: 0,
          pages_with_warnings: 0
        }
        
        config.after(:each, type: :system) do |example|
          # Skip if test failed or explicitly skipped
          next if example.exception
          next if example.metadata[:skip_a11y]

          # Skip if page wasn't visited
          begin
            current_path = example.example_group_instance.page.current_path
            next unless current_path
          rescue StandardError
            next
          end

          # Track this page test
          page_result = {
            path: current_path,
            errors: 0,
            warnings: 0,
            status: :pending
          }
          
          # Run comprehensive accessibility checks
          # Note: check_comprehensive_accessibility will:
          # - Raise if there are errors (test fails)
          # - Print warnings if there are warnings (test passes but shows warnings)
          # - Print success message if everything passes (no errors, no warnings)
          # - Return hash with :errors and :warnings counts
          instance = example.example_group_instance
          
          begin
            result = instance.check_comprehensive_accessibility
            
            # Get results from return value
            page_result[:errors] = result[:errors] || 0
            page_result[:warnings] = result[:warnings] || 0
            # Capture view_file if available from result
            page_result[:view_file] = result[:page_context][:view_file] if result[:page_context] && result[:page_context][:view_file]
            
            if page_result[:errors] > 0
              page_result[:status] = :failed
              @@accessibility_results[:pages_failed] += 1
              @@accessibility_results[:total_errors] += page_result[:errors]
            elsif page_result[:warnings] > 0
              page_result[:status] = :warning
              @@accessibility_results[:pages_with_warnings] += 1
              @@accessibility_results[:total_warnings] += page_result[:warnings]
            else
              page_result[:status] = :passed
              @@accessibility_results[:pages_passed] += 1
            end
            
            @@accessibility_results[:pages_tested] << page_result
          rescue StandardError => e
            # Accessibility check failed - extract error count from exception message or instance
            errors_count = 0
            warnings_count = 0
            
            # Try to extract counts from exception message first
            if e.message =~ /ACCESSIBILITY ERRORS FOUND: (\d+) error\(s\), (\d+) warning\(s\)/
              errors_count = $1.to_i
              warnings_count = $2.to_i
            elsif e.message =~ /(\d+) issue\(s\)/
              errors_count = $1.to_i
            else
              # Fallback: get from instance variables
              errors_count = instance.instance_variable_get(:@accessibility_errors)&.length || 1
              warnings_count = instance.instance_variable_get(:@accessibility_warnings)&.length || 0
            end
            
            # Ensure we have at least 1 error if exception was raised
            errors_count = 1 if errors_count == 0 && e.message.include?('ACCESSIBILITY ERRORS')
            
            page_result[:status] = :failed
            page_result[:errors] = errors_count
            page_result[:warnings] = warnings_count
            @@accessibility_results[:pages_failed] += 1
            @@accessibility_results[:total_errors] += errors_count
            @@accessibility_results[:total_warnings] += warnings_count
            @@accessibility_results[:pages_tested] << page_result
            
            # Flush stdout BEFORE setting exception to ensure errors are visible
            $stdout.flush
            $stderr.flush
            
            # Store error info in example metadata so it's available even if output is cleared
            example.metadata[:a11y_errors] = errors_count
            example.metadata[:a11y_warnings] = warnings_count
            example.metadata[:a11y_failed] = true
            
            # Set exception but don't clear output - keep errors visible
            example.set_exception(e)
            
            # Flush again after setting exception
            $stdout.flush
            $stderr.flush
          end
        end
        
        # Show overall summary after all tests complete
        config.after(:suite) do
          # Check if summary should be shown
          begin
            require 'rails_accessibility_testing/config/yaml_loader'
            profile = defined?(Rails) && Rails.env.test? ? :test : :development
            config_data = RailsAccessibilityTesting::Config::YamlLoader.load(profile: profile)
            summary_config = config_data['summary'] || {}
            show_summary = summary_config.fetch('show_summary', true)
            errors_only = summary_config.fetch('errors_only', false)
            
            return unless show_summary
            
            # Show summary if we tested any pages
            if @@accessibility_results && @@accessibility_results[:pages_tested].any?
              show_overall_summary(@@accessibility_results, errors_only: errors_only)
            end
          rescue StandardError => e
            # Silently fail if config can't be loaded
          end
        end
      end
      
      # Load summary configuration from YAML
      def load_summary_config
        require 'rails_accessibility_testing/config/yaml_loader'
        profile = defined?(Rails) && Rails.env.test? ? :test : :development
        config = RailsAccessibilityTesting::Config::YamlLoader.load(profile: profile)
        summary_config = config['summary'] || {}
        {
          'show_summary' => summary_config.fetch('show_summary', true),
          'errors_only' => summary_config.fetch('errors_only', false),
          'show_fixes' => summary_config.fetch('show_fixes', true)
        }
      end
      
      # Show overall summary of all pages tested
      def show_overall_summary(results, config_data = nil)
        return unless results && results[:pages_tested].any?
        
        # Load config if not provided
        config_data ||= load_summary_config
        
        # Filter out warnings if errors_only is true
        errors_only = config_data['errors_only']
        
        puts "\n" + "="*80
        puts "📊 COMPREHENSIVE ACCESSIBILITY TEST REPORT"
        puts "="*80
        puts ""
        puts "📈 Test Statistics:"
        puts "   Total pages tested: #{results[:pages_tested].length}"
        puts "   ✅ Passed (no issues):  #{results[:pages_passed]} page#{'s' if results[:pages_passed] != 1}"
        puts "   ❌ Failed (errors):     #{results[:pages_failed]} page#{'s' if results[:pages_failed] != 1}"
        unless errors_only
          puts "   ⚠️  Warnings only:      #{results[:pages_with_warnings]} page#{'s' if results[:pages_with_warnings] != 1}"
        end
        puts ""
        puts "📋 Total Issues Across All Pages:"
        puts "   ❌ Total errors:   #{results[:total_errors]}"
        unless errors_only
          puts "   ⚠️  Total warnings: #{results[:total_warnings]}"
        end
        puts ""
        
        # Show pages with errors (highest priority)
        pages_with_errors = results[:pages_tested].select { |p| p[:status] == :failed }
        if pages_with_errors.any?
          puts "❌ Pages with Errors (#{pages_with_errors.length}):"
          pages_with_errors.each do |page|
            view_file = page[:view_file] || page[:path]
            puts "   • #{view_file}"
            puts "     Errors: #{page[:errors]}#{", Warnings: #{page[:warnings]}" if page[:warnings] > 0 && !errors_only}"
            puts "     Path: #{page[:path]}" if page[:view_file] && page[:path] != view_file
          end
          puts ""
        end
        
        # Show pages with warnings only (only if not errors_only)
        unless errors_only
          pages_with_warnings_only = results[:pages_tested].select { |p| p[:status] == :warning }
          if pages_with_warnings_only.any?
            puts "⚠️  Pages with Warnings Only (#{pages_with_warnings_only.length}):"
            pages_with_warnings_only.each do |page|
              view_file = page[:view_file] || page[:path]
              puts "   • #{view_file}"
              puts "     Warnings: #{page[:warnings]}"
              puts "     Path: #{page[:path]}" if page[:view_file] && page[:path] != view_file
            end
            puts ""
          end
        end
        
        # Show summary of pages that passed (only if not errors_only)
        unless errors_only
          pages_passed = results[:pages_tested].select { |p| p[:status] == :passed }
          if pages_passed.any?
            if pages_passed.length <= 15
              puts "✅ Pages Passed All Checks (#{pages_passed.length}):"
              pages_passed.each do |page|
                puts "   ✓ #{page[:path]}"
              end
            else
              puts "✅ #{pages_passed.length} pages passed all accessibility checks"
              puts "   (Showing first 10):"
              pages_passed.first(10).each do |page|
                puts "   ✓ #{page[:path]}"
              end
              puts "   ... and #{pages_passed.length - 10} more"
            end
            puts ""
          end
        end
        
        # Final summary
        puts "="*80
        if results[:total_errors] > 0
          puts "❌ OVERALL STATUS: FAILED - #{results[:total_errors]} error#{'s' if results[:total_errors] != 1} found across #{results[:pages_failed]} page#{'s' if results[:pages_failed] != 1}"
        elsif !errors_only && results[:total_warnings] > 0
          puts "⚠️  OVERALL STATUS: PASSED WITH WARNINGS - #{results[:total_warnings]} warning#{'s' if results[:total_warnings] != 1} found"
        else
          puts "✅ OVERALL STATUS: PASSED - All #{results[:pages_tested].length} page#{'s' if results[:pages_tested].length != 1} passed accessibility checks!"
        end
        puts "="*80
        puts ""
      end
    end
  end
end

