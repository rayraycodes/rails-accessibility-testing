# frozen_string_literal: true

module RailsAccessibilityTesting
  # Simple helper to convert routes to testable paths
  class ChangeDetector
    class << self
      # Convert route to path string for testing
      # @param route [ActionDispatch::Journey::Route] The route object
      # @return [String, nil] The path string or nil if route can't be converted
      def route_to_path(route)
        return nil unless route.respond_to?(:path)
        return nil unless route.verb.to_s.include?('GET')
        
        path_spec = route.path.spec.to_s
        path = path_spec.dup
        path.gsub!(/\(\.:format\)/, '')
        path.gsub!(/\(:id\)/, '1')
        path.gsub!(/\(:(\w+)\)/, '1')
        path.gsub!(/\([^)]*\)/, '')
        path = '/' if path.empty? || path == '/'
        path = "/#{path}" unless path.start_with?('/')
        path.include?(':') ? nil : path
      end
    end
  end
end

