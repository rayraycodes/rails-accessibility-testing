# frozen_string_literal: true

# Capybara configuration for accessibility testing specs
# Provides helper methods for creating test pages and HTML fixtures

module CapybaraTestHelpers
  # Create a Capybara session with HTML content
  # @param html [String] HTML content to load
  # @return [Capybara::Session] Capybara session
  def create_page_with_html(html)
    session = Capybara::Session.new(:rack_test, TestApp.new(html))
    session
  end

  # Simple Rack app for testing
  class TestApp
    def initialize(html)
      @html = html
    end

    def call(env)
      [
        200,
        { 'Content-Type' => 'text/html' },
        [@html]
      ]
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraTestHelpers
end

