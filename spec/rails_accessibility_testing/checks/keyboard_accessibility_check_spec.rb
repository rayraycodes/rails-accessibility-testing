# frozen_string_literal: true

# Tests for KeyboardAccessibilityCheck
# WCAG 2.1 AA: 2.1.1 Keyboard (Level A)
#
# Verifies that modals and dialogs have focusable elements.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::KeyboardAccessibilityCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when modals have no focusable elements' do
      it_behaves_like 'detects violations', described_class, Invalid::MODAL_WITHOUT_FOCUSABLE, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::MODAL_WITHOUT_FOCUSABLE)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('keyboard_accessibility')
        expect(violation.message).to include('no focusable elements')
        expect(violation.wcag_reference).to eq('2.1.1')
      end
    end

    context 'when modals have focusable elements' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::MODAL_WITH_FOCUSABLE

      it 'accepts modals with buttons' do
        app = CapybaraTestHelpers::TestApp.new(Valid::MODAL_WITH_FOCUSABLE)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles hidden modals' do
        html = <<~HTML
          <html>
            <body>
              <div role="dialog" style="display: none;">
                <p>Hidden modal</p>
              </div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Hidden modals should not be checked (visible: true)
        expect(violations).to be_empty
      end

      it 'handles modals with various focusable elements' do
        html = <<~HTML
          <html>
            <body>
              <div role="dialog">
                <button>Close</button>
                <a href="/link">Link</a>
                <input type="text">
                <textarea></textarea>
                <select>
                  <option>Option</option>
                </select>
                <div tabindex="0">Focusable div</div>
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

      it 'handles elements with tabindex="-1"' do
        html = <<~HTML
          <html>
            <body>
              <div role="dialog">
                <button tabindex="-1">Not focusable</button>
              </div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # tabindex="-1" should not count as focusable
        expect(violations.length).to eq(1)
      end
    end
  end
end

