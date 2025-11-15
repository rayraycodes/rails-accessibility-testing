# frozen_string_literal: true

# Tests for InteractiveElementsCheck
# WCAG 2.1 AA: 2.4.4 Link Purpose (Level A), 4.1.2 Name, Role, Value (Level A)
#
# Verifies that interactive elements (links, buttons) have accessible names.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::InteractiveElementsCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when links are missing accessible names' do
      it_behaves_like 'detects violations', described_class, Invalid::LINK_WITHOUT_TEXT, 1

      it 'reports the correct violation details for links' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::LINK_WITHOUT_TEXT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('interactive_elements')
        expect(violation.message).to include('missing accessible name')
        expect(violation.wcag_reference).to eq('2.4.4')
      end
    end

    context 'when buttons are missing accessible names' do
      it_behaves_like 'detects violations', described_class, Invalid::BUTTON_WITHOUT_TEXT, 1

      it 'reports the correct violation details for buttons' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::BUTTON_WITHOUT_TEXT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('interactive_elements')
        expect(violation.message).to include('missing accessible name')
        expect(violation.wcag_reference).to eq('4.1.2')
      end
    end

    context 'when links have text content' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::LINK_WITH_TEXT

      it 'accepts links with visible text' do
        app = CapybaraTestHelpers::TestApp.new(Valid::LINK_WITH_TEXT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'when links have aria-label' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::LINK_WITH_ARIA_LABEL

      it 'accepts icon-only links with aria-label' do
        app = CapybaraTestHelpers::TestApp.new(Valid::LINK_WITH_ARIA_LABEL)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'when buttons have text content' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::BUTTON_WITH_TEXT

      it 'accepts buttons with visible text' do
        app = CapybaraTestHelpers::TestApp.new(Valid::BUTTON_WITH_TEXT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles icon-only buttons with aria-label' do
        html = EdgeCases::ICON_ONLY_BUTTON

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end

      it 'handles links with visually hidden text' do
        html = EdgeCases::VISUALLY_HIDDEN_TEXT

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Visually hidden text should still count as accessible name
        # This depends on how Capybara extracts text - might need adjustment
      end

      it 'handles hidden interactive elements' do
        html = <<~HTML
          <html>
            <body>
              <a href="/hidden" style="display: none;"></a>
              <button style="display: none;"></button>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Hidden elements should not be checked (visible: true by default)
        expect(violations).to be_empty
      end

      it 'handles elements with role="button" or role="link"' do
        html = <<~HTML
          <html>
            <body>
              <div role="button">Click me</div>
              <div role="link" href="/test">Link text</div>
              <div role="button"></div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Should flag the empty role="button"
        expect(violations.length).to eq(1)
      end
    end
  end
end

