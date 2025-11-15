# frozen_string_literal: true

# Tests for ImageAltTextCheck
# WCAG 2.1 AA: 1.1.1 Non-text Content (Level A)
#
# Verifies that images have alt attributes and that decorative images
# with empty alt="" are correctly handled.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::ImageAltTextCheck do
  include HtmlFixtures

  let(:check_class) { described_class }

  it_behaves_like 'an accessibility check', described_class

  describe '#check' do
    context 'when images are missing alt attributes' do
      it_behaves_like 'detects violations', described_class, Invalid::IMAGE_WITHOUT_ALT, 1

      it 'reports the correct violation details' do
        app = CapybaraTestHelpers::TestApp.new(Invalid::IMAGE_WITHOUT_ALT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: { url: '/test' })
        violations = check.check

        expect(violations.length).to eq(1)
        violation = violations.first

        expect(violation.rule_name).to eq('image_alt_text')
        expect(violation.message).to include('missing alt attribute')
        expect(violation.wcag_reference).to eq('1.1.1')
        expect(violation.remediation).to be_present
        expect(violation.element_context[:tag]).to eq('img')
        expect(violation.element_context[:src]).to be_present
      end
    end

    context 'when images have valid alt text' do
      it_behaves_like 'does not flag valid HTML', described_class, Valid::IMAGE_WITH_ALT

      it 'accepts images with descriptive alt text' do
        app = CapybaraTestHelpers::TestApp.new(Valid::IMAGE_WITH_ALT)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'when images are decorative (empty alt)' do
      it 'accepts decorative images with empty alt=""' do
        app = CapybaraTestHelpers::TestApp.new(Valid::IMAGE_DECORATIVE)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        expect(violations).to be_empty
      end
    end

    context 'edge cases' do
      it 'handles hidden images correctly' do
        # Hidden images should still be checked (visible: :all)
        html = <<~HTML
          <html>
            <body>
              <img src="logo.png" style="display: none;">
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Should detect missing alt even on hidden images
        expect(violations.length).to eq(1)
      end

      it 'handles multiple images correctly' do
        html = <<~HTML
          <html>
            <body>
              <img src="logo1.png" alt="Logo 1">
              <img src="logo2.png">
              <img src="logo3.png" alt="">
              <img src="logo4.png">
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Should detect 2 violations (logo2 and logo4)
        expect(violations.length).to eq(2)
        expect(violations.map { |v| v.element_context[:src] }).to contain_exactly('logo2.png', 'logo4.png')
      end

      it 'handles images without src attribute' do
        html = <<~HTML
          <html>
            <body>
              <img>
            </body>
          </html>
        HTML

        app = CapybaraTestHelpers::TestApp.new(html)
        page = Capybara::Session.new(:rack_test, app)
        page.visit('/')

        check = described_class.new(page: page, context: {})
        violations = check.check

        # Should still detect missing alt
        expect(violations.length).to eq(1)
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

