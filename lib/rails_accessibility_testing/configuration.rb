# frozen_string_literal: true

module RailsAccessibilityTesting
  # Configuration for the accessibility testing gem
  #
  # @example
  #   RailsAccessibilityTesting.configure do |config|
  #     config.auto_run_checks = true
  #   end
  #
  # @attr [Boolean] auto_run_checks Whether to automatically run checks after system specs
  # @attr [Logger, nil] logger Optional logger for accessibility check output
  class Configuration
    attr_accessor :auto_run_checks, :logger

    def initialize
      @auto_run_checks = true
      @logger = nil
    end
  end

  # Global configuration instance
  def self.config
    @config ||= Configuration.new
  end

  # Configure the gem
  def self.configure
    yield config if block_given?
  end
end

