# frozen_string_literal: true

# Tests for ErrorMessageBuilder
# Verifies that error messages are correctly formatted with all required information.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::ErrorMessageBuilder do
  let(:element_context) do
    {
      tag: 'img',
      id: 'logo',
      classes: 'header-logo',
      src: 'logo.png',
      text: '',
      parent: { tag: 'div', id: 'header' }
    }
  end

  let(:page_context) do
    {
      url: 'http://example.com/test',
      path: '/test',
      view_file: 'app/views/pages/test.html.erb'
    }
  end

  describe '.build' do
    it 'builds a complete error message' do
      message = described_class.build(
        error_type: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context
      )

      expect(message).to be_a(String)
      expect(message).to include('Image missing alt attribute')
      expect(message).to include('http://example.com/test')
      expect(message).to include('/test')
      expect(message).to include('app/views/pages/test.html.erb')
      expect(message).to include('<img>')
      expect(message).to include('logo.png')
    end

    it 'includes WCAG reference' do
      message = described_class.build(
        error_type: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context
      )

      expect(message).to include('WCAG Reference')
      expect(message).to include('https://www.w3.org/WAI/WCAG21/Understanding/')
    end

    it 'includes remediation steps' do
      message = described_class.build(
        error_type: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context
      )

      expect(message).to include('HOW TO FIX')
      expect(message).to include('alt')
    end

    context 'with different error types' do
      it 'generates appropriate remediation for form labels' do
        message = described_class.build(
          error_type: 'Form input missing label',
          element_context: { tag: 'input', id: 'email', input_type: 'email' },
          page_context: page_context
        )

        expect(message).to include('label')
        expect(message).to include('aria-label')
        expect(message).to include('email')
      end

      it 'generates appropriate remediation for interactive elements' do
        message = described_class.build(
          error_type: 'Link missing accessible name',
          element_context: { tag: 'a', href: '/about' },
          page_context: page_context
        )

        expect(message).to include('link_to')
        expect(message).to include('aria-label')
      end

      it 'generates appropriate remediation for heading hierarchy' do
        message = described_class.build(
          error_type: 'Heading hierarchy skipped (h1 to h3)',
          element_context: { tag: 'h3', text: 'Subsection' },
          page_context: page_context
        )

        expect(message).to include('h1')
        expect(message).to include('h2')
        expect(message).to include('h3')
      end
    end

    context 'with minimal context' do
      it 'handles missing optional information gracefully' do
        message = described_class.build(
          error_type: 'Test error',
          element_context: { tag: 'div' },
          page_context: { url: nil, path: nil, view_file: nil }
        )

        expect(message).to be_a(String)
        expect(message).to include('Test error')
        expect(message).to include('(unknown)')
      end
    end

    context 'with parent element information' do
      it 'includes parent element details' do
        message = described_class.build(
          error_type: 'Image missing alt attribute',
          element_context: element_context,
          page_context: page_context
        )

        expect(message).to include('Parent')
        expect(message).to include('<div')
        expect(message).to include('header')
      end
    end
  end
end

