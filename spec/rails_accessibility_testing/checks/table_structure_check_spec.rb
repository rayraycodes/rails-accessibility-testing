# frozen_string_literal: true

# Tests for TableStructureCheck
# WCAG 2.1 AA: 1.3.1 Info and Relationships (Level A)
#
# Verifies that tables have proper structure with headers.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::TableStructureCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when tables are missing headers' do
      it_behaves_like 'detects violations', described_class, Invalid::TABLE_WITHOUT_HEADERS, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::TABLE_WITHOUT_HEADERS)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('table_structure')
        expect(violation.message).to include('missing headers')
        expect(violation.wcag_reference).to eq('1.3.1')
      end
    end

    context 'when tables have headers' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::TABLE_WITH_HEADERS

      it 'accepts tables with <th> elements' do
        app = CapybaraTestHelpers::TestApp.new(Valid::TABLE_WITH_HEADERS)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles tables with caption' do
        html = <<~HTML
          <html>
            <body>
              <table>
                <caption>User Data</caption>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>John</td>
                    <td>john@example.com</td>
                  </tr>
                </tbody>
              </table>
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

      it 'handles multiple tables' do
        html = <<~HTML
          <html>
            <body>
              <table>
                <tr>
                  <th>Header</th>
                </tr>
              </table>
              <table>
                <tr>
                  <td>No header</td>
                </tr>
              </table>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations.length).to eq(1)  # Only second table should be flagged
      end
    end
  end
end

