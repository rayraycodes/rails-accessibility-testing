# frozen_string_literal: true

# Rails Accessibility Testing Gem
#
# Automatically configures accessibility testing for Rails system specs with
# comprehensive checks and detailed error messages.
#
# @version 1.0.0
# @author Regan Maharjan
#
# @example Basic usage
#   # In spec/rails_helper.rb
#   require 'rails_accessibility_testing'
#
#   # That's it! Comprehensive accessibility checks run automatically
#   # after each system spec that visits a page
#
# @example Manual checks in specs
#   it 'has no accessibility issues' do
#     visit root_path
#     check_comprehensive_accessibility  # All 11 checks
#   end
#
# @example Skip checks for specific tests
#   it 'does something', skip_a11y: true do
#     # This test won't run accessibility checks
#   end
#
# @see RailsAccessibilityTesting::AccessibilityHelper
# @see RailsAccessibilityTesting::ErrorMessageBuilder
# @see RailsAccessibilityTesting::RSpecIntegration

require 'axe-capybara'
require 'axe/matchers/be_axe_clean'

# Load version
begin
  require_relative 'rails_accessibility_testing/version'
rescue LoadError
  module RailsAccessibilityTesting
    VERSION = '1.0.0'
  end
end

# Load core components
require_relative 'rails_accessibility_testing/configuration'
require_relative 'rails_accessibility_testing/change_detector'
require_relative 'rails_accessibility_testing/error_message_builder'
require_relative 'rails_accessibility_testing/accessibility_helper'
require_relative 'rails_accessibility_testing/shared_examples'
require_relative 'rails_accessibility_testing/rspec_integration'

# Auto-configure when RSpec is available
if defined?(RSpec)
  RSpec.configure do |config|
    RailsAccessibilityTesting::RSpecIntegration.configure!(config)
  end
end
