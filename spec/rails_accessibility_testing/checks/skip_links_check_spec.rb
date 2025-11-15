# frozen_string_literal: true

# Tests for SkipLinksCheck
# WCAG 2.1 AA: 2.4.1 Bypass Blocks (Level A)
#
# Verifies that skip links are present and functional.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::SkipLinksCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'skip links check behavior' do
      it 'returns empty violations (warning-only check)' do
        html = <<~HTML
          <html>
            <body>
              <h1>Page without skip link</h1>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Skip links check is warning-only, returns empty violations
        expect(violations).to be_empty
      end

      it 'does not flag pages with skip links' do
        app = CapybaraTestHelpers::TestApp.new(Valid::SKIP_LINK)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles pages with no skip links gracefully' do
        html = <<~HTML
          <html>
            <body>
              <main>
                <h1>Content</h1>
              </main>
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
  end
end

