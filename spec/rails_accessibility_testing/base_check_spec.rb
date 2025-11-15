# frozen_string_literal: true

# Tests for BaseCheck
# Verifies common functionality shared by all accessibility checks.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Checks::BaseCheck do
  let(:page) { double('page') }
  let(:context) { { url: '/test', path: '/test' } }

  describe 'abstract class behavior' do
    it 'cannot be instantiated directly' do
      expect {
        RailsAccessibilityTesting::Checks::BaseCheck.new(page: page, context: context)
      }.to raise_error(NotImplementedError)
    end

    it 'requires subclasses to implement #check' do
      stub_const('TestCheck', Class.new(RailsAccessibilityTesting::Checks::BaseCheck) do
        def self.rule_name
          :test_check
        end
      end)

      test_check = TestCheck.new(page: page, context: context)
      expect { test_check.check }.to raise_error(NotImplementedError)
    end

    it 'requires subclasses to implement .rule_name' do
      stub_const('TestCheck', Class.new(RailsAccessibilityTesting::Checks::BaseCheck) do
        def check
          []
        end
      end)

      expect { TestCheck.rule_name }.to raise_error(NotImplementedError)
    end
  end

  describe 'common functionality' do
    let(:check_class) do
      Class.new(RailsAccessibilityTesting::Checks::BaseCheck) do
        def self.rule_name
          :test_check
        end

        def check
          []
        end
      end
    end

    let(:check) { check_class.new(page: page, context: context) }

    it 'stores page and context' do
      expect(check.page).to eq(page)
      expect(check.context).to eq(context)
    end

    it 'provides #run method that calls #check' do
      allow(check).to receive(:check).and_return([])
      check.run
      expect(check).to have_received(:check)
    end

    describe '#violation' do
      it 'creates a violation with all attributes' do
        allow(RailsAccessibilityTesting::Engine::Violation).to receive(:new).and_call_original

        check.send(:violation,
          message: 'Test violation',
          element_context: { tag: 'div' },
          wcag_reference: '1.1.1',
          remediation: 'Fix it'
        )

        expect(RailsAccessibilityTesting::Engine::Violation).to have_received(:new).with(
          rule_name: :test_check,
          message: 'Test violation',
          element_context: { tag: 'div' },
          page_context: anything,
          wcag_reference: '1.1.1',
          remediation: 'Fix it'
        )
      end
    end

    describe '#page_context' do
      it 'returns context with url, path, and view_file' do
        allow(page).to receive(:current_url).and_return('http://example.com/test')
        allow(page).to receive(:current_path).and_return('/test')

        page_ctx = check.send(:page_context)

        expect(page_ctx).to be_a(Hash)
        expect(page_ctx[:url]).to eq('http://example.com/test')
        expect(page_ctx[:path]).to eq('/test')
      end

      it 'handles errors gracefully' do
        allow(page).to receive(:current_url).and_raise(StandardError)
        allow(page).to receive(:current_path).and_raise(StandardError)

        page_ctx = check.send(:page_context)

        expect(page_ctx[:url]).to be_nil
        expect(page_ctx[:path]).to be_nil
      end
    end
  end
end

