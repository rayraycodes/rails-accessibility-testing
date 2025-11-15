# frozen_string_literal: true

# Tests for Violation
# Verifies that violations are correctly structured and serializable.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Engine::Violation do
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

  describe '#initialize' do
    it 'creates a violation with all attributes' do
      violation = described_class.new(
        rule_name: 'image_alt_text',
        message: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context,
        wcag_reference: '1.1.1',
        remediation: 'Add alt attribute'
      )

      expect(violation.rule_name).to eq('image_alt_text')
      expect(violation.message).to eq('Image missing alt attribute')
      expect(violation.element_context).to eq(element_context)
      expect(violation.page_context).to eq(page_context)
      expect(violation.wcag_reference).to eq('1.1.1')
      expect(violation.remediation).to eq('Add alt attribute')
    end

    it 'converts rule_name to string' do
      violation = described_class.new(
        rule_name: :image_alt_text,
        message: 'Test',
        element_context: {},
        page_context: {}
      )

      expect(violation.rule_name).to eq('image_alt_text')
    end

    it 'handles optional attributes' do
      violation = described_class.new(
        rule_name: 'form_labels',
        message: 'Test',
        element_context: {},
        page_context: {}
      )

      expect(violation.wcag_reference).to be_nil
      expect(violation.remediation).to be_nil
    end
  end

  describe '#to_h' do
    it 'converts violation to hash' do
      violation = described_class.new(
        rule_name: 'image_alt_text',
        message: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context,
        wcag_reference: '1.1.1',
        remediation: 'Add alt attribute'
      )

      hash = violation.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:rule_name]).to eq('image_alt_text')
      expect(hash[:message]).to eq('Image missing alt attribute')
      expect(hash[:element_context]).to eq(element_context)
      expect(hash[:page_context]).to eq(page_context)
      expect(hash[:wcag_reference]).to eq('1.1.1')
      expect(hash[:remediation]).to eq('Add alt attribute')
    end
  end

  describe '#to_json' do
    it 'converts violation to JSON string' do
      violation = described_class.new(
        rule_name: 'image_alt_text',
        message: 'Image missing alt attribute',
        element_context: element_context,
        page_context: page_context,
        wcag_reference: '1.1.1',
        remediation: 'Add alt attribute'
      )

      json = violation.to_json
      parsed = JSON.parse(json)

      expect(parsed['rule_name']).to eq('image_alt_text')
      expect(parsed['message']).to eq('Image missing alt attribute')
      expect(parsed['element_context']).to be_a(Hash)
      expect(parsed['page_context']).to be_a(Hash)
    end
  end
end

