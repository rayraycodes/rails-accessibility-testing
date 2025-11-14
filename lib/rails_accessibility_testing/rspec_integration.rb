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
        setup_automatic_checks(config) if RailsAccessibilityTesting.config.auto_run_checks
      end

      private

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
        config.include AccessibilityHelper, type: :system
      end

      # Setup automatic accessibility checks
      def setup_automatic_checks(config)
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

          # Run comprehensive accessibility checks
          instance = example.example_group_instance
          instance.check_comprehensive_accessibility
        rescue StandardError => e
          example.set_exception(e)
        end
      end
    end
  end
end

