# frozen_string_literal: true

# Rails Accessibility Testing Gem
#
# Automatically configures accessibility testing for Rails system specs with
# comprehensive checks and detailed error messages.
#
# @version 1.5.5
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
    VERSION = '1.5.0'
  end
end

# Load core components
require_relative 'rails_accessibility_testing/configuration'
require_relative 'rails_accessibility_testing/change_detector'
require_relative 'rails_accessibility_testing/file_change_tracker'
require_relative 'rails_accessibility_testing/error_message_builder'
require_relative 'rails_accessibility_testing/accessibility_helper'
# Static scanning components (modular and reusable)
require_relative 'rails_accessibility_testing/static_page_adapter'
require_relative 'rails_accessibility_testing/erb_extractor'
require_relative 'rails_accessibility_testing/line_number_finder'
require_relative 'rails_accessibility_testing/violation_converter'
require_relative 'rails_accessibility_testing/static_file_scanner'
require_relative 'rails_accessibility_testing/static_scanning'
require_relative 'rails_accessibility_testing/view_composition_builder'
require_relative 'rails_accessibility_testing/composed_page_scanner'
# Only load RSpec-specific components when RSpec is available
if defined?(RSpec)
  require_relative 'rails_accessibility_testing/shared_examples'
  require_relative 'rails_accessibility_testing/rspec_integration'
end

# Load engine components
require_relative 'rails_accessibility_testing/engine/violation'
require_relative 'rails_accessibility_testing/engine/violation_collector'
require_relative 'rails_accessibility_testing/engine/rule_engine'

# Load check definitions
require_relative 'rails_accessibility_testing/checks/base_check'
require_relative 'rails_accessibility_testing/checks/form_labels_check'
require_relative 'rails_accessibility_testing/checks/image_alt_text_check'
require_relative 'rails_accessibility_testing/checks/interactive_elements_check'
require_relative 'rails_accessibility_testing/checks/heading_check'
require_relative 'rails_accessibility_testing/checks/keyboard_accessibility_check'
require_relative 'rails_accessibility_testing/checks/aria_landmarks_check'
require_relative 'rails_accessibility_testing/checks/form_errors_check'
require_relative 'rails_accessibility_testing/checks/table_structure_check'
require_relative 'rails_accessibility_testing/checks/duplicate_ids_check'
require_relative 'rails_accessibility_testing/checks/skip_links_check'
require_relative 'rails_accessibility_testing/checks/color_contrast_check'

# Load configuration
require_relative 'rails_accessibility_testing/config/yaml_loader'

# Load integrations
require_relative 'rails_accessibility_testing/integration/minitest_integration'

# Load railtie (needed for generator discovery) - only if Rails is available
if defined?(Rails)
  require_relative 'rails_accessibility_testing/railtie'
end

# Auto-configure when RSpec is available
if defined?(RSpec)
  RSpec.configure do |config|
    RailsAccessibilityTesting::RSpecIntegration.configure!(config)
  end
end
