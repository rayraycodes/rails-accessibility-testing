# frozen_string_literal: true

# Tests for HeadingHierarchyCheck
# WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
#
# Verifies proper heading hierarchy (H1 present, no skipped levels).

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::HeadingHierarchyCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when page is missing H1' do
      it_behaves_like 'detects violations', described_class, Invalid::MISSING_H1, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::MISSING_H1)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('heading_hierarchy')
        expect(violation.message).to include('missing H1 heading')
        expect(violation.wcag_reference).to eq('1.3.1')
      end
    end

    context 'when heading levels are skipped' do
      it_behaves_like 'detects violations', described_class, Invalid::SKIPPED_HEADING_LEVEL, 1

      it 'reports skipped heading levels' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::SKIPPED_HEADING_LEVEL)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('heading_hierarchy')
        expect(violation.message).to include('Heading hierarchy skipped')
        expect(violation.message).to match(/h\d+ to h\d+/)
      end
    end

    context 'when heading hierarchy is valid' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::VALID_HEADING_HIERARCHY

      it 'accepts valid heading hierarchy' do
        app = CapybaraTestHelpers::TestApp.new(Valid::VALID_HEADING_HIERARCHY)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles pages with no headings' do
        html = <<~HTML
          <html>
            <body>
              <p>No headings here</p>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Pages with no headings should not violate (returns empty)
        expect(violations).to be_empty
      end

      it 'handles multiple H1 headings' do
        html = EdgeCases::MULTIPLE_H1

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Multiple H1s should not be a violation (just a warning in implementation)
        expect(violations).to be_empty
      end

      it 'handles complex heading structures' do
        html = <<~HTML
          <html>
            <body>
              <h1>Main</h1>
              <h2>Section 1</h2>
              <h3>Subsection 1.1</h3>
              <h3>Subsection 1.2</h3>
              <h2>Section 2</h2>
              <h3>Subsection 2.1</h3>
              <h4>Sub-subsection 2.1.1</h4>
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

      it 'handles headings in hidden sections' do
        html = <<~HTML
          <html>
            <body>
              <h1>Visible</h1>
              <div style="display: none;">
                <h2>Hidden</h2>
              </div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Only visible headings should be checked
        expect(violations).to be_empty
      end
    end
  end
end

