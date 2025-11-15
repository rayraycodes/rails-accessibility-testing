# frozen_string_literal: true

module RailsAccessibilityTesting
  module Checks
    # Base class for all accessibility checks
    #
    # Provides common functionality and defines the interface
    # that all checks must implement.
    #
    # @abstract Subclass and implement {#check} to create a new check
    #
    # @example Creating a custom check
    #   class MyCustomCheck < BaseCheck
    #     def self.rule_name
    #       :my_custom_check
    #     end
    #
    #     def check
    #       violations = []
    #       # Check logic here
    #       violations
    #     end
    #   end
    #
    # @api private
    class BaseCheck
      attr_reader :page, :context
      
      # Initialize the check
      # @param page [Capybara::Session] The page to check
      # @param context [Hash] Additional context (url, path, etc.)
      def initialize(page:, context: {})
        @page = page
        @context = context
      end
      
      # Run the check and return violations
      # @return [Array<Engine::Violation>]
      def run
        check
      end
      
      # The check implementation (must be overridden)
      # @return [Array<Engine::Violation>]
      def check
        raise NotImplementedError, "Subclass must implement #check"
      end
      
      # Rule name for this check (must be overridden)
      # @return [Symbol]
      def self.rule_name
        raise NotImplementedError, "Subclass must implement .rule_name"
      end
      
      protected
      
      # Create a violation
      # @param message [String] Error message
      # @param element_context [Hash] Element context
      # @param wcag_reference [String] WCAG reference
      # @param remediation [String] Suggested fix
      # @return [Engine::Violation]
      def violation(message:, element_context: {}, wcag_reference: nil, remediation: nil)
        Engine::Violation.new(
          rule_name: self.class.rule_name,
          message: message,
          element_context: element_context,
          page_context: page_context,
          wcag_reference: wcag_reference,
          remediation: remediation
        )
      end
      
      # Get page context
      # @return [Hash]
      def page_context
        {
          url: safe_page_url,
          path: safe_page_path,
          view_file: determine_view_file
        }
      end
      
      # Get element context from Capybara element
      # @param element [Capybara::Node::Element] The element
      # @return [Hash]
      def element_context(element)
        {
          tag: element.tag_name,
          id: element[:id],
          classes: element[:class],
          href: element[:href],
          src: element[:src],
          text: element.text.strip,
          parent: safe_parent_info(element)
        }
      end
      
      # Safely get page URL
      def safe_page_url
        page.current_url
      rescue StandardError
        nil
      end
      
      # Safely get page path
      def safe_page_path
        page.current_path
      rescue StandardError
        nil
      end
      
      # Safely get parent element info
      def safe_parent_info(element)
        parent = element.find(:xpath, '..')
        {
          tag: parent.tag_name,
          id: parent[:id],
          classes: parent[:class]
        }
      rescue StandardError
        nil
      end
      
      # Determine likely view file (simplified version)
      def determine_view_file
        return nil unless safe_page_path
        
        path = safe_page_path.split('?').first.split('#').first
        
        if defined?(Rails) && Rails.application
          begin
            route = Rails.application.routes.recognize_path(path)
            controller = route[:controller]
            action = route[:action]
            
            find_view_file_for_controller_action(controller, action)
          rescue StandardError
            nil
          end
        end
      end
      
      # Find view file for controller and action
      def find_view_file_for_controller_action(controller, action)
        extensions = %w[erb haml slim]
        extensions.each do |ext|
          view_path = "app/views/#{controller}/#{action}.html.#{ext}"
          return view_path if File.exist?(view_path)
        end
        nil
      end
    end
  end
end

