# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default, :development)

require 'rails_accessibility_testing'
require 'capybara/rspec'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'rack/test'

# Configure Capybara for testing
# Use rack_test for speed (no browser needed for most tests)
Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 2

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include Capybara DSL in all specs
  config.include Capybara::DSL

  # Clean up after each test
  config.after(:each) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

