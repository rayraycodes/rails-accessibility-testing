# frozen_string_literal: true

# Tests for FormErrorsCheck
# WCAG 2.1 AA: 3.3.1 Error Identification (Level A)
#
# Verifies that form error messages are associated with their inputs.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::FormErrorsCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when form errors are not associated' do
      it_behaves_like 'detects violations', described_class, Invalid::FORM_ERROR_NOT_ASSOCIATED, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::FORM_ERROR_NOT_ASSOCIATED)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('form_errors')
        expect(violation.message).to include('error message not associated')
        expect(violation.wcag_reference).to eq('3.3.1')
      end
    end

    context 'when form errors are associated' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::FORM_ERROR_ASSOCIATED

      it 'accepts inputs with aria-describedby' do
        app = CapybaraTestHelpers::TestApp.new(Valid::FORM_ERROR_ASSOCIATED)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles inputs without IDs' do
        html = <<~HTML
          <html>
            <body>
              <input type="text" class="is-invalid" name="email">
              <div class="error">Error message</div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Inputs without IDs are skipped (check requires id)
        expect(violations).to be_empty
      end

      it 'handles multiple error messages' do
        html = <<~HTML
          <html>
            <body>
              <input type="text" id="email" aria-invalid="true" aria-describedby="email-error">
              <div id="email-error" class="error">Email is required</div>
              <input type="password" id="password" aria-invalid="true">
              <div class="error">Password is required</div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Should flag password input (not associated)
        expect(violations.length).to eq(1)
      end
    end
  end
end

