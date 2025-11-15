# frozen_string_literal: true

# Tests for ViolationCollector
# Verifies that violations are correctly collected, aggregated, and summarized.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Engine::ViolationCollector do
  let(:collector) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty violations array' do
      expect(collector.violations).to eq([])
      expect(collector.any?).to be false
      expect(collector.count).to eq(0)
    end
  end

  describe '#add' do
    it 'adds violations to the collection' do
      violation1 = RailsAccessibilityTesting::Engine::Violation.new(
        rule_name: 'form_labels',
        message: 'Test violation 1',
        element_context: {},
        page_context: {}
      )

      violation2 = RailsAccessibilityTesting::Engine::Violation.new(
        rule_name: 'image_alt_text',
        message: 'Test violation 2',
        element_context: {},
        page_context: {}
      )

      collector.add([violation1, violation2])

      expect(collector.count).to eq(2)
      expect(collector.violations).to contain_exactly(violation1, violation2)
    end

    it 'handles single violation' do
      violation = RailsAccessibilityTesting::Engine::Violation.new(
        rule_name: 'form_labels',
        message: 'Test violation',
        element_context: {},
        page_context: {}
      )

      collector.add(violation)

      expect(collector.count).to eq(1)
      expect(collector.violations).to include(violation)
    end

    it 'handles empty array' do
      collector.add([])

      expect(collector.count).to eq(0)
    end
  end

  describe '#reset' do
    it 'clears all violations' do
      violation = RailsAccessibilityTesting::Engine::Violation.new(
        rule_name: 'form_labels',
        message: 'Test violation',
        element_context: {},
        page_context: {}
      )

      collector.add(violation)
      expect(collector.count).to eq(1)

      collector.reset

      expect(collector.count).to eq(0)
      expect(collector.violations).to eq([])
    end
  end

  describe '#any?' do
    it 'returns false when no violations' do
      expect(collector.any?).to be false
    end

    it 'returns true when violations exist' do
      violation = RailsAccessibilityTesting::Engine::Violation.new(
        rule_name: 'form_labels',
        message: 'Test violation',
        element_context: {},
        page_context: {}
      )

      collector.add(violation)
      expect(collector.any?).to be true
    end
  end

  describe '#count' do
    it 'returns correct count' do
      expect(collector.count).to eq(0)

      3.times do |i|
        violation = RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'form_labels',
          message: "Test violation #{i}",
          element_context: {},
          page_context: {}
        )
        collector.add(violation)
      end

      expect(collector.count).to eq(3)
    end
  end

  describe '#grouped_by_rule' do
    it 'groups violations by rule name' do
      violations = [
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'form_labels',
          message: 'Form violation 1',
          element_context: {},
          page_context: {}
        ),
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'form_labels',
          message: 'Form violation 2',
          element_context: {},
          page_context: {}
        ),
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'image_alt_text',
          message: 'Image violation',
          element_context: {},
          page_context: {}
        )
      ]

      collector.add(violations)

      grouped = collector.grouped_by_rule

      expect(grouped.keys).to contain_exactly('form_labels', 'image_alt_text')
      expect(grouped['form_labels'].length).to eq(2)
      expect(grouped['image_alt_text'].length).to eq(1)
    end
  end

  describe '#summary' do
    it 'returns summary statistics' do
      violations = [
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'form_labels',
          message: 'Form violation 1',
          element_context: {},
          page_context: {}
        ),
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'form_labels',
          message: 'Form violation 2',
          element_context: {},
          page_context: {}
        ),
        RailsAccessibilityTesting::Engine::Violation.new(
          rule_name: 'image_alt_text',
          message: 'Image violation',
          element_context: {},
          page_context: {}
        )
      ]

      collector.add(violations)

      summary = collector.summary

      expect(summary[:total]).to eq(3)
      expect(summary[:by_rule]).to eq({
        'form_labels' => 2,
        'image_alt_text' => 1
      })
      expect(summary[:rules_affected]).to eq(2)
    end

    it 'returns empty summary when no violations' do
      summary = collector.summary

      expect(summary[:total]).to eq(0)
      expect(summary[:by_rule]).to eq({})
      expect(summary[:rules_affected]).to eq(0)
    end
  end
end

