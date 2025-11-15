# frozen_string_literal: true

# Tests for DuplicateIdsCheck
# WCAG 2.1 AA: 4.1.1 Parsing (Level A)
#
# Verifies that all IDs on a page are unique.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::DuplicateIdsCheck do
  include HtmlFixtures

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when duplicate IDs are found' do
      it_behaves_like 'detects violations', described_class, Invalid::DUPLICATE_IDS, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::DUPLICATE_IDS)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('duplicate_ids')
        expect(violation.message).to include('Duplicate IDs found')
        expect(violation.wcag_reference).to eq('4.1.1')
        expect(violation.element_context[:duplicate_ids]).to be_an(Array)
      end
    end

    context 'when all IDs are unique' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::UNIQUE_IDS

      it 'accepts pages with unique IDs' do
        app = CapybaraTestHelpers::TestApp.new(Valid::UNIQUE_IDS)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles multiple duplicate IDs' do
        html = <<~HTML
          <html>
            <body>
              <div id="content">Content 1</div>
              <div id="content">Content 2</div>
              <div id="sidebar">Sidebar 1</div>
              <div id="sidebar">Sidebar 2</div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first
        expect(violation.element_context[:duplicate_ids]).to contain_exactly('content', 'sidebar')
      end

      it 'handles elements without IDs' do
        html = <<~HTML
          <html>
            <body>
              <div>No ID</div>
              <div>Also no ID</div>
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

      it 'handles empty IDs' do
        html = <<~HTML
          <html>
            <body>
              <div id="">Empty ID 1</div>
              <div id="">Empty ID 2</div>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Empty IDs should be filtered out (compact)
        expect(violations).to be_empty
      end
    end
  end
end

