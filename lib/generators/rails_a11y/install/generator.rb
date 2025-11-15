# frozen_string_literal: true

require 'rails/generators/base'

module RailsAccessibilityTesting
  module Generators
    # Generator to install Rails Accessibility Testing
    #
    # Creates initializer and configuration file.
    #
    # @example
    #   rails generate rails_a11y:install
    #
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      desc "Install Rails A11y: creates initializer and configuration file"
      
      def create_initializer
        template 'initializer.rb.erb', 'config/initializers/rails_a11y.rb'
      end
      
      def create_config_file
        template 'accessibility.yml.erb', 'config/accessibility.yml'
      end
      
      def add_to_rails_helper
        rails_helper_path = 'spec/rails_helper.rb'
        
        if File.exist?(rails_helper_path)
          inject_into_file rails_helper_path,
            after: "require 'rspec/rails'\n" do
            "require 'rails_accessibility_testing'\n"
          end
        else
          say "⚠️  spec/rails_helper.rb not found. Please add: require 'rails_accessibility_testing'", :yellow
        end
      end
      
      def show_instructions
        say "\n✅ Rails Accessibility Testing installed successfully!", :green
        say "\nNext steps:", :yellow
        say "  1. Run your system specs: bundle exec rspec spec/system/"
        say "  2. Accessibility checks will run automatically"
        say "  3. Configure checks in config/accessibility.yml"
        say "\nFor more information, see: https://github.com/rayraycodes/rails-accessibility-testing"
      end
    end
  end
end

