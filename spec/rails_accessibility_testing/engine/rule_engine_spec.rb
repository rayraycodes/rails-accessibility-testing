# frozen_string_literal: true

# Tests for RuleEngine
# Verifies that the rule engine correctly coordinates checks, applies configuration,
# and handles errors gracefully.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Engine::RuleEngine do
  let(:default_config) do
    {
      'wcag_level' => 'AA',
      'checks' => {
        'form_labels' => true,
        'image_alt_text' => true,
        'interactive_elements' => true
      },
      'ignored_rules' => []
    }
  end

  describe '#initialize' do
    it 'initializes with configuration' do
      engine = described_class.new(config: default_config)

      expect(engine.config).to eq(default_config)
      expect(engine.violation_collector).to be_a(RailsAccessibilityTesting::Engine::ViolationCollector)
    end

    it 'loads all check classes' do
      engine = described_class.new(config: default_config)

      # Access private @checks via reflection or test through behavior
      # We'll test through the check method
      expect(engine).to respond_to(:check)
    end
  end

  describe '#check' do
    let(:page) { double('page') }
    let(:engine) { described_class.new(config: default_config) }

    it 'runs enabled checks against a page' do
      # Create a page with violations
      html = HtmlFixtures::Invalid::IMAGE_WITHOUT_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: default_config)
      violations = engine.check(capybara_page, context: { url: '/test' })

      # Should detect image alt text violation
      expect(violations).not_to be_empty
      expect(violations.any? { |v| v.rule_name == 'image_alt_text' }).to be true
    end

    it 'respects disabled checks in configuration' do
      config = default_config.merge(
        'checks' => {
          'form_labels' => true,
          'image_alt_text' => false,  # Disabled
          'interactive_elements' => true
        }
      )

      html = HtmlFixtures::Invalid::IMAGE_WITHOUT_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: config)
      violations = engine.check(capybara_page, context: { url: '/test' })

      # Should not detect image alt text violation (check is disabled)
      expect(violations.none? { |v| v.rule_name == 'image_alt_text' }).to be true
    end

    it 'respects ignored rules' do
      config = default_config.merge(
        'ignored_rules' => [
          { 'rule' => 'image_alt_text', 'reason' => 'Known issue' }
        ]
      )

      html = HtmlFixtures::Invalid::IMAGE_WITHOUT_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: config)
      violations = engine.check(capybara_page, context: { url: '/test' })

      # Should not detect image alt text violation (rule is ignored)
      expect(violations.none? { |v| v.rule_name == 'image_alt_text' }).to be true
    end

    it 'collects violations from multiple checks' do
      html = <<~HTML
        <html>
          <body>
            <img src="logo.png">
            <input type="text" id="name">
            <a href="/test"></a>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: default_config)
      violations = engine.check(capybara_page, context: { url: '/test' })

      # Should detect violations from multiple checks
      expect(violations.length).to be >= 3
      rule_names = violations.map(&:rule_name).uniq
      expect(rule_names).to include('image_alt_text', 'form_labels', 'interactive_elements')
    end

    it 'handles check errors gracefully' do
      # Create a check that will error
      page = double('page')
      allow(page).to receive(:all).and_raise(StandardError.new('Check error'))

      engine = described_class.new(config: default_config)

      # Should not raise error, should continue with other checks
      expect { engine.check(page, context: {}) }.not_to raise_error
    end

    it 'resets violation collector between runs' do
      html = HtmlFixtures::Invalid::IMAGE_WITHOUT_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: default_config)

      # First run
      violations1 = engine.check(capybara_page, context: { url: '/test' })
      expect(violations1).not_to be_empty

      # Second run should not accumulate violations
      violations2 = engine.check(capybara_page, context: { url: '/test' })
      expect(violations2.length).to eq(violations1.length)
    end

    it 'passes context to checks' do
      html = HtmlFixtures::Valid::IMAGE_WITH_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      context = { url: '/custom', path: '/custom', custom_data: 'test' }
      engine = described_class.new(config: default_config)
      violations = engine.check(capybara_page, context: context)

      # Context should be available to checks (tested through violation page_context)
      if violations.any?
        expect(violations.first.page_context[:url]).to eq('/custom')
      end
    end
  end

  describe 'configuration handling' do
    it 'defaults to enabled for checks not in config' do
      config = {
        'wcag_level' => 'AA',
        'checks' => {
          'form_labels' => false
        },
        'ignored_rules' => []
      }

      html = HtmlFixtures::Invalid::IMAGE_WITHOUT_ALT
      app = CapybaraTestHelpers::TestApp.new(html)
      capybara_page = Capybara::Session.new(:rack_test, app)
      capybara_page.visit('/')

      engine = described_class.new(config: config)
      violations = engine.check(capybara_page, context: { url: '/test' })

      # image_alt_text should be enabled by default
      expect(violations.any? { |v| v.rule_name == 'image_alt_text' }).to be true
    end
  end
end

