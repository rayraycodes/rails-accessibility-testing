# frozen_string_literal: true

require 'nokogiri'

module RailsAccessibilityTesting
  # Adapter that makes a Nokogiri document look like a Capybara page
  # This allows existing checks to work with static file scanning
  class StaticPageAdapter
    attr_reader :doc, :view_file

    def initialize(html_content, view_file:)
      @doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
      @view_file = view_file
      @line_map = build_line_map(html_content)
    end

    # Capybara-like interface: page.all('selector', visible: :all)
    def all(selector, visible: true)
      elements = @doc.css(selector)
      # Filter by visibility if needed (for now, return all)
      elements.map { |el| StaticElementAdapter.new(el, self) }
    end

    # Capybara-like interface: page.has_css?('selector')
    def has_css?(selector, wait: true)
      @doc.css(selector).any?
    end

    # Capybara-like interface: page.current_url
    def current_url
      nil # Not applicable for static files
    end

    # Capybara-like interface: page.current_path
    def current_path
      nil # Not applicable for static files
    end

    # Get line number for an element (delegated to scanner)
    def line_number_for(element)
      # This will be set by the scanner if needed
      nil
    end
  end

  # Adapter that makes a Nokogiri element look like a Capybara element
  class StaticElementAdapter
    attr_reader :native, :adapter

    def initialize(nokogiri_element, adapter)
      @element = nokogiri_element
      @adapter = adapter
      @native = nokogiri_element
    end

    # Capybara-like interface: element.tag_name
    def tag_name
      @element.name
    end

    # Capybara-like interface: element[:id]
    def [](attribute)
      @element[attribute]
    end

    # Capybara-like interface: element.text
    def text
      @element.text
    end

    # Capybara-like interface: element.visible?
    def visible?
      # For static scanning, assume all elements are visible
      # Could be enhanced to check CSS display/visibility
      true
    end

    # Capybara-like interface: element.find(:xpath, '..')
    def find(selector_type, xpath)
      if selector_type == :xpath && xpath == '..'
        parent = @element.parent
        return StaticElementAdapter.new(parent, @adapter) if parent && parent.element?
        nil
      end
      nil
    rescue StandardError
      nil
    end

    # Get line number for this element
    def line_number
      @adapter.line_number_for(@element)
    end

    # Convert to HTML string
    def to_html
      @element.to_html
    end

    # Support for native.attribute() calls used by checks
    def native
      NativeWrapper.new(@element)
    end

    # Wrapper for native element attribute access
    class NativeWrapper
      def initialize(element)
        @element = element
      end

      def attribute(name)
        @element[name]
      end
    end
  end
end

