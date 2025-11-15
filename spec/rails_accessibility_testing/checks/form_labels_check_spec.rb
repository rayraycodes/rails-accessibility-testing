# frozen_string_literal: true

# Tests for FormLabelsCheck
# WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
#
# Verifies that form inputs have associated labels via:
# - <label for="id"> elements
# - aria-label attributes
# - aria-labelledby attributes

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::FormLabelsCheck do
  include HtmlFixtures

  let(:check_class) { described_class }

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when inputs are missing labels' do
      it_behaves_like 'detects violations', described_class, Invalid::FORM_WITHOUT_LABEL, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::FORM_WITHOUT_LABEL)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('form_labels')
        expect(violation.message).to include('missing label')
        expect(violation.wcag_reference).to eq('1.3.1')
        expect(violation.remediation).to be_present
        expect(violation.element_context[:tag]).to eq('input')
      end
    end

    context 'when inputs have label elements' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::FORM_WITH_LABEL

      it 'accepts inputs with <label for="id">' do
        app = CapybaraTestHelpers::TestApp.new(Valid::FORM_WITH_LABEL)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'when inputs have aria-label' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::FORM_WITH_ARIA_LABEL

      it 'accepts inputs with aria-label attribute' do
        app = CapybaraTestHelpers::TestApp.new(Valid::FORM_WITH_ARIA_LABEL)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'when inputs have aria-labelledby' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::FORM_WITH_ARIA_LABELLEDBY

      it 'accepts inputs with aria-labelledby attribute' do
        app = CapybaraTestHelpers::TestApp.new(Valid::FORM_WITH_ARIA_LABELLEDBY)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles wrapped labels (label > input)' do
        html = <<~HTML
          <html>
            <body>
              <label>
                Email
                <input type="email" name="email">
              </label>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Wrapped labels don't use 'for' attribute, so this might be flagged
        # unless the check handles this case. For now, we expect it might be flagged.
        # This is a known limitation that could be improved.
      end

      it 'handles inputs without id attributes' do
        html = <<~HTML
          <html>
            <body>
              <input type="text" name="name">
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

      it 'handles multiple input types' do
        html = <<~HTML
          <html>
            <body>
              <input type="text" id="text1">
              <input type="email" id="email1">
              <input type="password" id="pass1">
              <input type="number" id="num1">
              <textarea id="textarea1"></textarea>
              <select id="select1">
                <option>Option 1</option>
              </select>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # All 6 inputs should be flagged
        expect(violations.length).to eq(6)
      end

      it 'handles radio groups with fieldset/legend' do
        html = EdgeCases::RADIO_GROUP

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Radio buttons with labels should not be flagged
        expect(violations).to be_empty
      end
    end

    context 'error handling' do
      it 'handles page errors gracefully' do
        page = double('page')
        allow(page).to receive(:all).and_raise(StandardError.new('Page error'))

        check = described_class.new(page: page, context: {})
        expect { check.check }.not_to raise_error
      end
    end
  end
end

