# frozen_string_literal: true

# Tests for Configuration
# Verifies that configuration is correctly initialized and can be modified.

require 'spec_helper'

RSpec.describe RailsAccessibilityTesting::Configuration do
  describe '.config' do
    it 'returns a configuration instance' do
      config = RailsAccessibilityTesting.config

      expect(config).to be_a(RailsAccessibilityTesting::Configuration)
    end

    it 'returns the same instance on subsequent calls' do
      config1 = RailsAccessibilityTesting.config
      config2 = RailsAccessibilityTesting.config

      expect(config1).to be(config2)
    end
  end

  describe '.configure' do
    it 'yields the configuration instance' do
      RailsAccessibilityTesting.configure do |config|
        expect(config).to be_a(RailsAccessibilityTesting::Configuration)
      end
    end

    it 'allows modifying configuration' do
      RailsAccessibilityTesting.configure do |config|
        config.auto_run_checks = false
      end

      expect(RailsAccessibilityTesting.config.auto_run_checks).to be false
    end
  end

  describe '#initialize' do
    it 'initializes with default values' do
      config = RailsAccessibilityTesting::Configuration.new

      expect(config.auto_run_checks).to be true
    end
  end

  describe '#auto_run_checks' do
    it 'can be set and retrieved' do
      config = RailsAccessibilityTesting::Configuration.new

      config.auto_run_checks = false
      expect(config.auto_run_checks).to be false

      config.auto_run_checks = true
      expect(config.auto_run_checks).to be true
    end
  end
end

