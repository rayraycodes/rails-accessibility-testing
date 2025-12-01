# frozen_string_literal: true

require_relative '../accessibility_helper'

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
      # Include partial detection methods from AccessibilityHelper
      include AccessibilityHelper::PartialDetection
      
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
          page_context: page_context(element_context),
          wcag_reference: wcag_reference,
          remediation: remediation
        )
      end
      
      # Get page context
      # @param element_context [Hash] Optional element context to help find partials
      # @return [Hash]
      def page_context(element_context = nil)
        # For static scanning, use view_file from context if available
        if @context && @context[:view_file]
          {
            url: nil,
            path: nil,
            view_file: @context[:view_file]
          }
        else
          {
            url: safe_page_url,
            path: safe_page_path,
            view_file: determine_view_file(element_context)
          }
        end
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
      
      # Determine likely view file (simplified version for checks)
      # Uses same priority logic as AccessibilityHelper:
      # 1. View file (yield content) - most common
      # 2. Partials in view file
      # 3. Layout partials
      # 4. Layout file
      def determine_view_file(element_context = nil)
        return nil unless safe_page_path
        
        path = safe_page_path.split('?').first.split('#').first
        
        if defined?(Rails) && Rails.application
          begin
            route = Rails.application.routes.recognize_path(path)
            controller = route[:controller]
            action = route[:action]
            
            # Priority 1: View file (yield content)
            view_file = find_view_file_for_controller_action(controller, action)
            
            # Priority 2: Partials rendered in the view file
            if view_file && element_context
              partials_in_view = find_partials_in_view_file(view_file)
              
              if partials_in_view.any?
                partial_file = find_partial_for_element_in_list(controller, element_context, partials_in_view)
                return partial_file if partial_file
              end
            end
            
            # Priority 3: Layout partials (if element is in layout area)
            if element_context
              # Use the same element_in_layout? logic from AccessibilityHelper
              # Check if element is likely in layout (navbar, footer, etc.)
              parent = element_context[:parent]
              if parent
                parent_tag = parent[:tag].to_s.downcase
                parent_id = parent[:id].to_s.downcase
                
                # Skip if inside <main> (yield content)
                unless parent_tag == 'main' || parent_id.include?('maincontent') || parent_id.include?('main-content')
                  layout_indicators = ['navbar', 'nav', 'footer', 'header', 'main-nav', 'sidebar', 'skip']
                  classes = parent[:classes].to_s.downcase
                  id = parent[:id].to_s.downcase
                  
                  if layout_indicators.any? { |indicator| classes.include?(indicator) || id.include?(indicator) }
                    layout_partial = find_partial_in_layouts(element_context)
                    return layout_partial if layout_partial
                  end
                end
              end
            end
            
            # Return view file (yield content) - most common case
            view_file
          rescue StandardError
            nil
          end
        end
      end
      
      # Find view file for controller and action
      # Handles cases where action name doesn't match view file name
      def find_view_file_for_controller_action(controller, action)
        extensions = %w[erb haml slim]
        controller_path = "app/views/#{controller}"
        
        # First, try exact matches
        extensions.each do |ext|
          view_paths = [
            "#{controller_path}/#{action}.html.#{ext}",
            "#{controller_path}/_#{action}.html.#{ext}",
            "#{controller_path}/#{action}.#{ext}"
          ]
          
          found = view_paths.find { |vp| File.exist?(vp) }
          return found if found
        end
        
        # If exact match not found, scan all view files in the controller directory
        # This handles cases like: search action -> search_result.html.erb
        if File.directory?(controller_path)
          extensions.each do |ext|
            # Look for files that might match the action (e.g., search_result, search_results, etc.)
            pattern = "#{controller_path}/*#{action}*.html.#{ext}"
            matching_files = Dir.glob(pattern)
            
            # Prefer files that start with the action name
            preferred = matching_files.find { |f| File.basename(f).start_with?("#{action}_") || File.basename(f).start_with?("#{action}.") }
            return preferred if preferred
            
            # Return first match if any found
            return matching_files.first if matching_files.any?
          end
        end
        
        nil
      end
    end
  end
end

