# frozen_string_literal: true

# Tests for AriaLandmarksCheck
# WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
#
# Verifies that pages have proper ARIA landmarks, especially main landmark.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::AriaLandmarksCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when page is missing main landmark' do
      it_behaves_like 'detects violations', described_class, Invalid::MISSING_MAIN_LANDMARK, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::MISSING_MAIN_LANDMARK)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('aria_landmarks')
        expect(violation.message).to include('missing MAIN landmark')
        expect(violation.wcag_reference).to eq('1.3.1')
      end
    end

    context 'when page has main landmark' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::MAIN_LANDMARK

      it 'accepts pages with <main> element' do
        app = CapybaraTestHelpers::TestApp.new(Valid::MAIN_LANDMARK)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end

      it 'accepts pages with role="main"' do
        html = <<~HTML
          <html>
            <body>
              <div role="main">
                <h1>Content</h1>
              </div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles multiple main landmarks' do
        html = <<~HTML
          <html>
            <body>
              <main>First main</main>
              <main>Second main</main>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Multiple mains should not be a violation (just a warning in implementation)
        expect(violations).to be_empty
      end

      it 'handles hidden main landmarks' do
        html = <<~HTML
          <html>
            <body>
              <main style="display: none;">
                <h1>Hidden content</h1>
              </main>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Hidden landmarks should not be checked (visible: true)
        expect(violations.length).to eq(1)  # Should still flag missing visible main
      end
    end
  end
end

