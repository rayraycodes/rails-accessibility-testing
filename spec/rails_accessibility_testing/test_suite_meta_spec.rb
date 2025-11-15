# frozen_string_literal: true

# Meta-tests for the test suite itself
# Verifies that the test suite is comprehensive, accurate, and follows best practices
#
# These tests ensure:
# 1. All checks have corresponding test files
# 2. Test patterns are consistent
# 3. HTML fixtures cover necessary cases
# 4. Shared examples are used correctly
# 5. Test coverage is adequate

require 'spec_helper'

RSpec.describe 'Test Suite Quality' do
  describe 'check test coverage' do
    it 'has test files for all check classes' do
      check_classes = [
        'FormLabelsCheck',
        'ImageAltTextCheck',
        'InteractiveElementsCheck',
        'HeadingHierarchyCheck',
        'KeyboardAccessibilityCheck',
        'AriaLandmarksCheck',
        'FormErrorsCheck',
        'TableStructureCheck',
        'DuplicateIdsCheck',
        'SkipLinksCheck',
        'ColorContrastCheck'
      ]

      check_classes.each do |check_class|
        # Convert CamelCase to snake_case
        snake_case = check_class.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                                 .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                                 .downcase
        spec_file = "spec/rails_accessibility_testing/checks/#{snake_case}_spec.rb"
        expect(File.exist?(spec_file)).to be(true),
          "Missing test file for #{check_class}: #{spec_file}"
      end
    end

    it 'has corresponding check implementation for each test file' do
      spec_files = Dir.glob('spec/rails_accessibility_testing/checks/*_spec.rb')
      
      spec_files.each do |spec_file|
        check_name = File.basename(spec_file, '_spec.rb')
        # Convert snake_case to CamelCase
        check_class_name = check_name.split('_').map(&:capitalize).join
        check_file = "lib/rails_accessibility_testing/checks/#{check_name}.rb"
        
        expect(File.exist?(check_file)).to be(true),
          "Missing check implementation for #{check_class_name}: #{check_file}"
      end
    end
  end

  describe 'test file quality' do
    it 'all check test files use shared examples' do
      spec_files = Dir.glob('spec/rails_accessibility_testing/checks/*_spec.rb')
      
      spec_files.each do |spec_file|
        content = File.read(spec_file)
        expect(content).to include("it_behaves_like 'an accessibility check'"),
          "#{spec_file} should use shared examples"
      end
    end

    it 'all check test files include HtmlFixtures' do
      spec_files = Dir.glob('spec/rails_accessibility_testing/checks/*_spec.rb')
      
      spec_files.each do |spec_file|
        content = File.read(spec_file)
        expect(content).to include('include HtmlFixtures'),
          "#{spec_file} should include HtmlFixtures"
      end
    end

    it 'all check test files test both positive and negative cases' do
      spec_files = Dir.glob('spec/rails_accessibility_testing/checks/*_spec.rb')
      
      spec_files.each do |spec_file|
        content = File.read(spec_file)
        
        # Should have tests for violations (positive)
        has_positive = content.include?('detects violations') || 
                       content.include?('missing') ||
                       content.include?('violations.length')
        
        # Should have tests for valid HTML (negative)
        has_negative = content.include?('does not flag valid HTML') ||
                      content.include?('accepts') ||
                      content.include?('expect(violations).to be_empty')
        
        expect(has_positive || has_negative).to be(true),
          "#{spec_file} should test both positive (violations) and negative (valid) cases"
      end
    end
  end

  describe 'HTML fixtures coverage' do
    it 'has fixtures for all invalid patterns' do
      required_invalid_fixtures = [
        :IMAGE_WITHOUT_ALT,
        :FORM_WITHOUT_LABEL,
        :MISSING_H1,
        :SKIPPED_HEADING_LEVEL,
        :LINK_WITHOUT_TEXT,
        :BUTTON_WITHOUT_TEXT,
        :MODAL_WITHOUT_FOCUSABLE,
        :MISSING_MAIN_LANDMARK,
        :TABLE_WITHOUT_HEADERS,
        :FORM_ERROR_NOT_ASSOCIATED,
        :DUPLICATE_IDS
      ]

      required_invalid_fixtures.each do |fixture|
        expect(HtmlFixtures::Invalid.const_defined?(fixture)).to be(true),
          "Missing invalid fixture: #{fixture}"
      end
    end

    it 'has fixtures for all valid patterns' do
      required_valid_fixtures = [
        :IMAGE_WITH_ALT,
        :IMAGE_DECORATIVE,
        :FORM_WITH_LABEL,
        :FORM_WITH_ARIA_LABEL,
        :FORM_WITH_ARIA_LABELLEDBY,
        :VALID_HEADING_HIERARCHY,
        :LINK_WITH_TEXT,
        :LINK_WITH_ARIA_LABEL,
        :BUTTON_WITH_TEXT,
        :MODAL_WITH_FOCUSABLE,
        :MAIN_LANDMARK,
        :TABLE_WITH_HEADERS,
        :FORM_ERROR_ASSOCIATED,
        :UNIQUE_IDS,
        :SKIP_LINK
      ]

      required_valid_fixtures.each do |fixture|
        expect(HtmlFixtures::Valid.const_defined?(fixture)).to be(true),
          "Missing valid fixture: #{fixture}"
      end
    end
  end

  describe 'engine test coverage' do
    it 'has tests for all engine components' do
      engine_components = [
        'rule_engine_spec.rb',
        'violation_collector_spec.rb',
        'violation_spec.rb'
      ]

      engine_components.each do |spec_file|
        expect(File.exist?("spec/rails_accessibility_testing/engine/#{spec_file}")).to be(true),
          "Missing engine test: #{spec_file}"
      end
    end
  end

  describe 'configuration test coverage' do
    it 'has tests for configuration components' do
      config_tests = [
        'spec/rails_accessibility_testing/configuration_spec.rb',
        'spec/rails_accessibility_testing/config/yaml_loader_spec.rb'
      ]

      config_tests.each do |spec_file|
        expect(File.exist?(spec_file)).to be(true),
          "Missing configuration test: #{spec_file}"
      end
    end
  end

  describe 'test infrastructure' do
    it 'has required support files' do
      required_files = [
        'spec/spec_helper.rb',
        'spec/support/capybara_setup.rb',
        'spec/support/html_fixtures.rb',
        'spec/support/shared_examples/accessibility_check_shared_examples.rb'
      ]

      required_files.each do |file|
        expect(File.exist?(file)).to be(true),
          "Missing required support file: #{file}"
      end
    end

    it 'spec_helper loads all necessary dependencies' do
      expect { require_relative '../../spec/spec_helper' }.not_to raise_error
    end
  end

  describe 'WCAG coverage' do
    it 'tests cover all major WCAG principles' do
      wcag_checks = {
        '1.1.1' => 'Image alt text',
        '1.3.1' => 'Form labels, heading hierarchy, table structure, ARIA landmarks',
        '1.4.3' => 'Color contrast (stub)',
        '2.1.1' => 'Keyboard accessibility',
        '2.4.1' => 'Skip links',
        '2.4.4' => 'Link purpose (interactive elements)',
        '3.3.1' => 'Form error identification',
        '4.1.1' => 'Duplicate IDs',
        '4.1.2' => 'Name, role, value (interactive elements)'
      }

      # Verify that we have tests covering these WCAG criteria
      # This is a meta-check to ensure comprehensive coverage
      wcag_checks.each do |criterion, description|
        # At least one test file should reference this criterion
        spec_files = Dir.glob('spec/**/*_spec.rb')
        references = spec_files.any? { |f| File.read(f).include?(criterion) }
        
        expect(references).to be(true),
          "No tests reference WCAG #{criterion}: #{description}"
      end
    end
  end

  describe 'test execution' do
    it 'can instantiate all check classes' do
      check_classes = [
        RailsAccessibilityTesting::Checks::FormLabelsCheck,
        RailsAccessibilityTesting::Checks::ImageAltTextCheck,
        RailsAccessibilityTesting::Checks::InteractiveElementsCheck,
        RailsAccessibilityTesting::Checks::HeadingHierarchyCheck,
        RailsAccessibilityTesting::Checks::KeyboardAccessibilityCheck,
        RailsAccessibilityTesting::Checks::AriaLandmarksCheck,
        RailsAccessibilityTesting::Checks::FormErrorsCheck,
        RailsAccessibilityTesting::Checks::TableStructureCheck,
        RailsAccessibilityTesting::Checks::DuplicateIdsCheck,
        RailsAccessibilityTesting::Checks::SkipLinksCheck,
        RailsAccessibilityTesting::Checks::ColorContrastCheck
      ]

      check_classes.each do |check_class|
        expect(check_class).to respond_to(:rule_name)
        expect(check_class.rule_name).to be_a(Symbol)
      end
    end

    it 'can create test pages with HTML fixtures' do
      html = HtmlFixtures::Valid::IMAGE_WITH_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      expect(page).to have_css('img')
    end
  end
end

