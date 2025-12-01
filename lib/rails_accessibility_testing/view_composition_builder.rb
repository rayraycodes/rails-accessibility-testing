# frozen_string_literal: true

require 'set'
require 'nokogiri'
require_relative 'accessibility_helper'
require_relative 'erb_extractor'

# Builds a composition graph of a Rails page (layout + view + partials)
# This allows us to check heading hierarchy across the complete composed page
# rather than individual files
module RailsAccessibilityTesting
  # Builds the composition of a Rails page by tracing:
  # - Layout file (application.html.erb)
  # - View file (yield content)
  # - All partials rendered (recursively)
  #
  # @api private
  class ViewCompositionBuilder
    include AccessibilityHelper::PartialDetection

    attr_reader :view_file, :layout_file, :all_files

    def initialize(view_file)
      @view_file = view_file
      @layout_file = nil
      @all_files = []
      @visited_files = Set.new
    end

    # Build the complete composition
    # @return [Array<String>] Array of all file paths in the composition
    def build
      # Resolve view file path (handle relative/absolute)
      view_file_path = normalize_path(@view_file)
      return [] unless view_file_path && File.exist?(view_file_path)

      @all_files = []
      @visited_files = Set.new

      # Find layout file
      @layout_file = find_layout_file_for_view(view_file_path)
      if @layout_file
        layout_path = normalize_path(@layout_file)
        @all_files << layout_path if layout_path && File.exist?(layout_path)
      end

      # Recursively find all partials (handles nested partials, collections, etc.)
      # Note: find_all_partials_recursive adds files to @all_files and @visited_files
      # We call it BEFORE manually adding to ensure it processes the file
      find_all_partials_recursive(view_file_path)
      if @layout_file
        layout_path = normalize_path(@layout_file)
        find_all_partials_recursive(layout_path) if layout_path
      end
      
      # Ensure view file is in @all_files (it should be added by find_all_partials_recursive)
      @all_files << view_file_path unless @all_files.include?(view_file_path)

      @all_files.uniq
    end
    
    # Normalize file path to consistent format (absolute if possible)
    def normalize_path(file_path)
      return nil unless file_path
      
      # Try with Rails.root first (most reliable for Rails apps)
      if defined?(Rails) && Rails.root
        rails_path = Rails.root.join(file_path)
        return rails_path.to_s if File.exist?(rails_path)
      end
      
      # If file exists as-is (relative or absolute), return it
      return file_path if File.exist?(file_path)
      
      # Try making it absolute if it's relative
      if !file_path.start_with?('/')
        expanded = File.expand_path(file_path)
        return expanded if File.exist?(expanded)
      end
      
      # Return original if nothing works (will be checked later)
      file_path
    end

    # Get all headings from the complete composition
    # @return [Array<Hash>] Array of heading info: { level: 1-6, text: String, file: String, line: Integer }
    def all_headings
      headings = []

      @all_files.each do |file|
        # Handle both relative and absolute paths
        file_path = if File.exist?(file)
          file
        elsif defined?(Rails) && Rails.root
          rails_path = Rails.root.join(file)
          rails_path.exist? ? rails_path.to_s : nil
        else
          nil
        end
        
        next unless file_path && File.exist?(file_path)

        content = File.read(file_path)
        html_content = ErbExtractor.extract_html(content)
        doc = Nokogiri::HTML::DocumentFragment.parse(html_content)

        doc.css('h1, h2, h3, h4, h5, h6').each do |heading|
          level = heading.name[1].to_i
          text = heading.text.strip
          line = find_line_number(content, heading)

          headings << {
            level: level,
            text: text,
            file: file_path,  # Use resolved path
            line: line
          }
        end
      end

      # Sort by file order (layout first, then view, then partials)
      # This preserves the DOM order
      headings.sort_by do |h|
        file_index = @all_files.index(h[:file]) || 999
        [file_index, h[:line]]
      end
    end

    private

    # Find layout file for a view
    # Handles:
    # - Explicit layout declaration in view: layout 'custom_layout'
    # - Controller-level layout (via ApplicationController)
    # - Default application layout
    def find_layout_file_for_view(view_file)
      return nil unless view_file && File.exist?(view_file)

      # Check for layout declaration in view file
      content = File.read(view_file)
      layout_match = content.match(/layout\s+['"]([^'"]+)['"]/)
      layout_name = layout_match ? layout_match[1] : 'application'

      # Try to find layout file
      extensions = %w[erb haml slim]
      extensions.each do |ext|
        layout_path = "app/views/layouts/#{layout_name}.html.#{ext}"
        if File.exist?(layout_path)
          return layout_path
        elsif defined?(Rails) && Rails.root
          rails_path = Rails.root.join(layout_path)
          return rails_path.to_s if File.exist?(rails_path)
        end
      end

      # Default to application layout
      extensions.each do |ext|
        layout_path = "app/views/layouts/application.html.#{ext}"
        if File.exist?(layout_path)
          return layout_path
        elsif defined?(Rails) && Rails.root
          rails_path = Rails.root.join(layout_path)
          return rails_path.to_s if File.exist?(rails_path)
        end
      end

      nil
    end

    # Recursively find all partials rendered in a file
    # Handles nested partials, collections, and all Rails render patterns
    def find_all_partials_recursive(file)
      # Normalize file path to consistent format
      file_path = normalize_path(file)
      return unless file_path && File.exist?(file_path)
      return if @visited_files.include?(file_path)

      @visited_files.add(file_path)
      content = File.read(file_path)

      # Find all partials rendered in this file
      # Use the PartialDetection module method (handles all Rails patterns)
      partials = find_partials_in_view_file(file_path)
      
      # Also check for Rails shorthand: render @model (renders _model.html.erb)
      content.scan(/render\s+@(\w+)/) do |match|
        model_name = match[0]
        partial_name = model_name.underscore
        partials << partial_name unless partials.include?(partial_name)
      end

      partials.each do |partial_name|
        partial_file = find_partial_file(partial_name)
        next unless partial_file
        
        # Normalize partial file path to consistent format
        full_partial_path = normalize_path(partial_file)
        next unless full_partial_path && File.exist?(full_partial_path)
        next if @all_files.include?(full_partial_path)

        @all_files << full_partial_path

        # Recursively find partials within this partial (handles nested partials)
        find_all_partials_recursive(full_partial_path)
      end
    end

    # Find the actual file path for a partial name
    def find_partial_file(partial_name)
      extensions = %w[erb haml slim]

      # Handle namespaced partials (e.g., 'layouts/_navbar', 'layouts/navbar')
      if partial_name.include?('/')
        parts = partial_name.split('/')
        dir = parts[0..-2].join('/')
        name = parts.last
        # Remove leading underscore from name if present
        name = name.start_with?('_') ? name[1..-1] : name
        partial_path = "app/views/#{dir}/_#{name}"
        
        extensions.each do |ext|
          full_path = "#{partial_path}.html.#{ext}"
          # Try with Rails.root first (most reliable)
          if defined?(Rails) && Rails.root
            rails_path = Rails.root.join(full_path)
            return rails_path.to_s if File.exist?(rails_path)
          end
          # Fallback to relative path
          if File.exist?(full_path)
            return full_path
          end
        end
      else
        # Non-namespaced partial - remove leading underscore if present
        clean_name = partial_name.start_with?('_') ? partial_name[1..-1] : partial_name
        
        # Try view directory first (same directory as view file)
        # Handle both absolute and relative paths
        view_dir_path = File.dirname(@view_file)
        if view_dir_path.include?('app/views/')
          # Extract directory relative to app/views
          view_dir = view_dir_path.sub(/^.*\/app\/views\//, '')
        else
          view_dir = view_dir_path.sub('app/views/', '')
        end
        partial_path = "app/views/#{view_dir}/_#{clean_name}"
        
        extensions.each do |ext|
          full_path = "#{partial_path}.html.#{ext}"
          # Try with Rails.root if file doesn't exist (for absolute paths)
          if File.exist?(full_path)
            return full_path
          elsif defined?(Rails) && Rails.root
            rails_path = Rails.root.join(full_path)
            return rails_path.to_s if File.exist?(rails_path)
          end
        end

        # Try standard directories first (most common locations)
        standard_dirs = ['layouts', 'shared', 'application']
        standard_dirs.each do |dir|
          partial_path = "app/views/#{dir}/_#{clean_name}"
          extensions.each do |ext|
            full_path = "#{partial_path}.html.#{ext}"
            # Try with Rails.root first
            if defined?(Rails) && Rails.root
              rails_path = Rails.root.join(full_path)
              return rails_path.to_s if File.exist?(rails_path)
            end
            # Fallback to relative path
            if File.exist?(full_path)
              return full_path
            end
          end
        end
        
        # Exhaustive search: traverse ALL folders in app/views recursively
        # This ensures we find partials in any subdirectory (collections, items, profiles, loan_requests, etc.)
        # Only do this if partial wasn't found in standard locations (performance optimization)
        if defined?(Rails) && Rails.root
          views_dir = Rails.root.join('app', 'views')
          if File.exist?(views_dir)
            # Search for partial in all subdirectories (use first match found)
            extensions.each do |ext|
              pattern = views_dir.join('**', "_#{clean_name}.html.#{ext}")
              found_path = Dir.glob(pattern).first
              return found_path if found_path && File.exist?(found_path)
            end
          end
        end
      end

      nil
    end

    # Find line number for an element in the original ERB file
    def find_line_number(content, element)
      # Simple approach: find the line containing the tag
      tag_name = element.name
      text = element.text.strip[0..50] # First 50 chars for matching

      lines = content.split("\n")
      lines.each_with_index do |line, index|
        if line.include?("<#{tag_name}") && (text.empty? || line.include?(text[0..20]))
          return index + 1
        end
      end

      1 # Default to line 1 if not found
    end
  end
end

