# frozen_string_literal: true

module RailsAccessibilityTesting
  module Integration
    # Minitest integration for accessibility testing
    #
    # Provides helpers and automatic checks for Minitest system tests.
    #
    # @example
    #   # In test/test_helper.rb
    #   require 'rails_accessibility_testing/integration/minitest_integration'
    #   RailsAccessibilityTesting::Integration::MinitestIntegration.setup!
    #
    # @example In a system test
    #   class HomePageTest < ActionDispatch::SystemTestCase
    #     test "home page is accessible" do
    #       visit root_path
    #       # Accessibility checks run automatically
    #     end
    #   end
    #
    module MinitestIntegration
      class << self
        # Setup Minitest integration
        # @param config [Hash] Optional configuration
        def setup!(config: {})
          return unless defined?(ActionDispatch::SystemTestCase)
          
          include_helpers
          setup_automatic_checks if RailsAccessibilityTesting.config.auto_run_checks
        end
        
        private
        
        # Include accessibility helpers in system tests
        def include_helpers
          ActionDispatch::SystemTestCase.class_eval do
            include RailsAccessibilityTesting::AccessibilityHelper
          end
        end
        
        # Setup automatic checks after each system test
        def setup_automatic_checks
          ActionDispatch::SystemTestCase.class_eval do
            teardown do
              # Skip if test failed or explicitly skipped
              next if failure || skip_a11y?
              
              # Skip if page wasn't visited
              begin
                current_path = page.current_path
                next unless current_path
              rescue StandardError
                next
              end
              
              # Run comprehensive accessibility checks
              check_comprehensive_accessibility
            rescue StandardError => e
              flunk("Accessibility check failed: #{e.message}")
            end
          end
        end
      end
      
      # Helper method to check if a11y should be skipped
      def skip_a11y?
        # Check for skip_a11y metadata or method
        respond_to?(:skip_a11y) && skip_a11y
      end
    end
  end
end

