# frozen_string_literal: true

# Only define Railtie if Rails is available
if defined?(Rails)
  module RailsAccessibilityTesting
    # Railtie for Rails integration
    # Makes generators available to Rails
    class Railtie < Rails::Railtie
      # Generators are automatically discovered by Rails
      # when they're in lib/generators/ directory
      
      # Add middleware for live scanning in development
      initializer 'rails_accessibility_testing.middleware' do |app|
        if Rails.env.development?
          require 'rails_accessibility_testing/middleware/page_visit_logger'
          app.middleware.use RailsAccessibilityTesting::Middleware::PageVisitLogger
        end
      end
    end
  end
end

