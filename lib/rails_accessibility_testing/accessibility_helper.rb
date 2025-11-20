# frozen_string_literal: true

# Accessibility helper methods for system specs
#
# Provides comprehensive accessibility checks with detailed error messages.
# This module is automatically included in all system specs when the gem is required.
#
# NOTE: This helper uses the RuleEngine and checks from the checks/ folder
# to ensure consistency between RSpec tests and CLI commands.
#
# @example Using in a system spec
#   it 'has no accessibility issues' do
#     visit root_path
#     check_comprehensive_accessibility
#   end
#
# @example Individual checks
#   check_image_alt_text
#   check_form_labels
#   check_interactive_elements_have_names
#
# @see RailsAccessibilityTesting::ErrorMessageBuilder For error message formatting
# @see RailsAccessibilityTesting::Engine::RuleEngine For the underlying check engine
module RailsAccessibilityTesting
  module AccessibilityHelper
    # Track scanned pages to avoid duplicate checks
    @scanned_pages = {}
    
    class << self
      attr_accessor :scanned_pages
    end
    
    # Module for partial detection methods (can be included in BaseCheck)
    module PartialDetection
      # Find partials rendered in a view file by scanning its content
      def find_partials_in_view_file(view_file)
        return [] unless view_file && File.exist?(view_file)
        
        content = File.read(view_file)
        partials = []
        
        # Match various Rails partial render patterns:
        # render 'partial_name'
        # render partial: 'partial_name'
        # render "partial_name"
        # render partial: "partial_name"
        # render 'path/to/partial'
        # render partial: 'path/to/partial'
        # <%= render 'partial_name' %>
        # <%= render partial: 'partial_name' %>
        
        patterns = [
          /render\s+(?:partial:\s*)?['"]([^'"]+)['"]/,
          /render\s+(?:partial:\s*)?:(\w+)/,
          /<%=?\s*render\s+(?:partial:\s*)?['"]([^'"]+)['"]/,
          /<%=?\s*render\s+(?:partial:\s*)?:(\w+)/
        ]
        
        patterns.each do |pattern|
          content.scan(pattern) do |match|
            partial_name = match[0] || match[1]
            next unless partial_name
            
            # Normalize partial name (remove leading slash, handle paths)
            partial_name = partial_name.strip
            partial_name = partial_name[1..-1] if partial_name.start_with?('/')
            
            # Handle namespaced partials (e.g., 'layouts/navbar' -> 'layouts/_navbar')
            if partial_name.include?('/')
              parts = partial_name.split('/')
              partial_name = "#{parts[0..-2].join('/')}/_#{parts.last}"
            else
              partial_name = "_#{partial_name}" unless partial_name.start_with?('_')
            end
            
            partials << partial_name unless partials.include?(partial_name)
          end
        end
        
        partials
      end
      
      # Find partial file that might contain the element, checking a specific list of partials
      def find_partial_for_element_in_list(controller, element_context, partial_list)
        return nil unless element_context && partial_list.any?
        
        extensions = %w[erb haml slim]
        
        # Check each partial in the list
        partial_list.each do |partial_name|
          # Remove leading underscore if present (we'll add it back)
          clean_name = partial_name.start_with?('_') ? partial_name[1..-1] : partial_name
          
          extensions.each do |ext|
            # Handle namespaced partials (e.g., 'layouts/navbar')
            if clean_name.include?('/')
              partial_path = "app/views/#{clean_name}.html.#{ext}"
            else
              # Check in controller directory, shared, and layouts
              partial_paths = [
                "app/views/#{controller}/_#{clean_name}.html.#{ext}",
                "app/views/shared/_#{clean_name}.html.#{ext}",
                "app/views/layouts/_#{clean_name}.html.#{ext}"
              ]
              
              partial_paths.each do |pp|
                return pp if File.exist?(pp)
              end
              next
            end
            
            return partial_path if File.exist?(partial_path)
          end
        end
        
        nil
      end
    end
    
    # Include PartialDetection in AccessibilityHelper so methods are available
    include PartialDetection
    
  # Get current page context for error messages
  # @param element_context [Hash] Optional element context to help determine exact view file
  # @return [Hash] Page context with url, path, and view_file
  def get_page_context(element_context = nil)
    {
      url: safe_page_url,
      path: safe_page_path,
      view_file: determine_view_file(safe_page_path, safe_page_url, element_context)
    }
  end

  # Get element context for error messages
  # @param element [Capybara::Node::Element] The element to get context for
  # @return [Hash] Element context with tag, id, classes, etc.
  def get_element_context(element)
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

  # Basic accessibility check - runs 5 basic checks
  def check_basic_accessibility
    @accessibility_errors ||= []
    @accessibility_warnings ||= []
    
    check_form_labels
    check_image_alt_text
    check_interactive_elements_have_names
    check_heading_hierarchy
    check_keyboard_accessibility
    
    # If we collected any errors and this was called directly (not from comprehensive), raise them
    if @accessibility_errors.any? && !@in_comprehensive_check
      # Show warnings first if any
      if @accessibility_warnings.any?
        puts format_all_warnings(@accessibility_warnings)
      end
      raise format_all_errors(@accessibility_errors)
    elsif @accessibility_errors.empty? && !@in_comprehensive_check
      # Show warnings if any (non-blocking)
      if @accessibility_warnings.any?
        puts format_all_warnings(@accessibility_warnings)
      end
      # Show success message when all checks pass
      timestamp = format_timestamp_for_terminal
      puts "\n✅ All basic accessibility checks passed! (5 checks: form labels, images, interactive elements, headings, keyboard)"
      puts "   ✓ #{timestamp}"
    end
  end

  # Full comprehensive check - runs all 11 checks including advanced
  # Uses the RuleEngine and checks from the checks/ folder for consistency
  # @return [Hash] Hash with :errors and :warnings counts
  def check_comprehensive_accessibility
    # Note: Page scanning cache is disabled for RSpec tests to ensure accurate error reporting
    # The cache is only used in live scanner to avoid duplicate scans
    
    @accessibility_errors = []
    @accessibility_warnings = []
    @in_comprehensive_check = true
    
    # Show page being checked - simplified header
    page_path = safe_page_path || 'current page'
    page_url = safe_page_url || 'current URL'
    view_file = determine_view_file(page_path, page_url, {})
    
    puts "\n" + "="*70
    puts "🔍 Scanning: #{view_file || page_path}"
    puts "="*70
    print "  Running checks"
    $stdout.flush
    
    # Use RuleEngine to run checks from checks/ folder
    begin
      config = RailsAccessibilityTesting::Config::YamlLoader.load(profile: :development)
      engine = RailsAccessibilityTesting::Engine::RuleEngine.new(config: config)
      
      context = {
        url: safe_page_url,
        path: safe_page_path
      }
      
      # Progress callback for real-time feedback - show dots only
      progress_callback = lambda do |check_number, total_checks, check_name, status, data = nil|
        case status
        when :start
          print "."
          $stdout.flush
        when :passed
          # Already printed dot, no need to print anything
        when :found_issues
          # Already printed dot, no need to print anything
        when :error
          # Already printed dot, no need to print anything
        end
      end
      
      violations = engine.check(page, context: context, progress_callback: progress_callback)
      
      # Print newline after dots
      puts ""
      
      # Convert violations to our error/warning format
      violations.each do |violation|
        element_context = violation.element_context || {}
        page_context = {
          url: context[:url],
          path: context[:path],
          view_file: determine_view_file(context[:path], context[:url], element_context)
        }
        
        # Skip links and aria landmarks are warnings, everything else is an error
        # Multiple h1s should be errors, not warnings
        if violation.message.include?('skip link') || violation.message.include?('Skip link') || 
           (violation.rule_name == 'aria_landmarks')
          collect_warning(violation.message, element_context, page_context)
        else
          collect_error(violation.message, element_context, page_context)
        end
      end
    rescue StandardError => e
      # Fallback to old method if RuleEngine fails
    check_basic_accessibility
    check_aria_landmarks
    check_form_error_associations
    check_table_structure
    check_duplicate_ids
      check_skip_links
    end
    
    @in_comprehensive_check = false
    
    # Get page context for success messages
    page_context_info = {
      path: safe_page_path,
      url: safe_page_url,
      view_file: determine_view_file(safe_page_path, safe_page_url, {})
    }
    
    # Show summary separator
    puts ""
    puts "="*70
    
    # Centralized report: Show everything together in one unified report
    timestamp = format_timestamp_for_terminal
    
    # Build unified report - errors first, then warnings, then success
    if @accessibility_errors.any?
      # Store counts before raising (so they're available even if exception is caught)
      error_count = @accessibility_errors.length
      warning_count = @accessibility_warnings.length
      
      # Show errors first (most critical)
      error_output = format_all_errors(@accessibility_errors)
      puts error_output
      $stdout.flush  # Flush immediately to ensure errors are visible
      
      # Check if we're in live scanner mode (detect by checking caller)
      is_live_scanner = caller.any? { |line| line.include?('a11y_live_scanner') }
      
      # Show warnings after errors (if any) - but skip in live scanner
      if @accessibility_warnings.any? && !is_live_scanner
        warning_output = format_all_warnings(@accessibility_warnings)
        puts warning_output
        $stdout.flush
      end
      
      # Summary - make it very clear
      puts "\n" + "="*70
      puts "📊 SUMMARY: Found #{error_count} ERROR#{'S' if error_count != 1}"
      puts "   #{warning_count} warning#{'s' if warning_count != 1}" if warning_count > 0 && !is_live_scanner
      puts "="*70
      $stdout.flush
      
      # Raise to fail the test (errors already formatted above)
      # Include error and warning counts in message so they can be extracted even if exception is caught
      raise "ACCESSIBILITY ERRORS FOUND: #{error_count} error(s), #{warning_count} warning(s) - see details above"
    elsif @accessibility_warnings.any?
      # Check if we're in live scanner mode - skip warnings in live scanner
      is_live_scanner = caller.any? { |line| line.include?('a11y_live_scanner') }
      
      if !is_live_scanner
        # Only warnings, no errors - show warnings and indicate test passed with warnings
        puts format_all_warnings(@accessibility_warnings)
        puts "\n" + "="*70
        puts "📊 SUMMARY: Test passed with #{@accessibility_warnings.length} warning#{'s' if @accessibility_warnings.length != 1}"
        puts "   ✓ #{timestamp}"
        puts "="*70
        puts "\n✅ Accessibility checks completed with warnings (test passed, but please address warnings above)"
        puts "   📄 Page: #{page_context_info[:path] || 'current page'}"
        puts "   📝 View: #{page_context_info[:view_file] || 'unknown'}"
      else
        # Live scanner - just show success
        puts "\n" + "="*70
        puts "✅ All checks passed (no errors)"
        puts "="*70
      end
    else
      # All checks passed with no errors and no warnings - show success message
      puts "📊 SUMMARY: All checks passed!"
      puts "="*70
      puts "\n✅ All comprehensive accessibility checks passed! (11 checks: form labels, images, interactive elements, headings, keyboard, ARIA landmarks, form errors, table structure, duplicate IDs, skip links, color contrast)"
      puts "   📄 Page: #{page_context_info[:path] || 'current page'}"
      puts "   📝 View: #{page_context_info[:view_file] || 'unknown'}"
      puts "   ✓ #{timestamp}"
    end
    
    # Return counts for tracking and page context
    # Note: This return statement only executes if no exception was raised above
    # If errors were found, an exception is raised and this never executes
    result = {
      errors: @accessibility_errors.length,
      warnings: @accessibility_warnings.length,
      skipped: false,
      page_context: page_context_info
    }
    
    # Ensure output is flushed before returning
    $stdout.flush
    
    result
  end
  
  # Reset the scanned pages cache (useful for testing or when you want to rescan)
  def reset_scanned_pages_cache
    AccessibilityHelper.scanned_pages.clear
  end

  private

  # Format timestamp for terminal output (shorter, more readable)
  def format_timestamp_for_terminal
    # Use just time for same-day reports, or full date if different day
    # Format: "13:27:43" (cleaner for terminal)
    Time.now.strftime("%H:%M:%S")
  end

  # Collect an error instead of raising immediately
  def collect_error(error_type, element_context, page_context)
    error_message = build_error_message(error_type, element_context, page_context)
    @accessibility_errors << {
      error_type: error_type,
      element_context: element_context,
      page_context: page_context,
      message: error_message
    }
  end

  # Collect a warning (non-blocking, but formatted like errors)
  def collect_warning(warning_type, element_context, page_context)
    @accessibility_warnings ||= []
    warning_message = build_error_message(warning_type, element_context, page_context)
    @accessibility_warnings << {
      warning_type: warning_type,
      element_context: element_context,
      page_context: page_context,
      message: warning_message
    }
  end

  # Format all collected errors with summary at top and details at bottom
  def format_all_errors(errors)
    return "" if errors.empty?
    
    timestamp = format_timestamp_for_terminal
    
    output = []
    output << "\n" + "="*70
    output << "❌ ACCESSIBILITY ERRORS FOUND: #{errors.length} issue(s) • #{timestamp}"
    output << "="*70
    output << ""
    output << "📋 SUMMARY OF ISSUES:"
    output << ""
    
    # Summary list at top
    errors.each_with_index do |error, index|
      error_type = error[:error_type]
      page_context = error[:page_context]
      element_context = error[:element_context]
      
      # Build summary line - prioritize view file
      summary = "   #{index + 1}. #{error_type}"
      
      # Add view file prominently first
      if page_context[:view_file]
        summary += "\n      📝 File: #{page_context[:view_file]}"
      end
      
      # Add element identifier if available
      if element_context[:id].present?
        summary += "\n      🔍 Element: [id: #{element_context[:id]}]"
      elsif element_context[:href].present?
        href_display = element_context[:href].length > 40 ? "#{element_context[:href][0..37]}..." : element_context[:href]
        summary += "\n      🔍 Element: [href: #{href_display}]"
      elsif element_context[:src].present?
        src_display = element_context[:src].length > 40 ? "#{element_context[:src][0..37]}..." : element_context[:src]
        summary += "\n      🔍 Element: [src: #{src_display}]"
      end
      
      # Add path as fallback if no view file
      if !page_context[:view_file] && page_context[:path]
        summary += "\n      🔗 Path: #{page_context[:path]}"
      end
      
      output << summary
    end
    
    output << ""
    output << "="*70
    output << "📝 DETAILED ERROR DESCRIPTIONS:"
    output << "="*70
    output << ""
    
    # Detailed descriptions at bottom
    errors.each_with_index do |error, index|
      output << "\n" + "-"*70
      output << "ERROR #{index + 1} of #{errors.length}:"
      output << "-"*70
      output << error[:message]
    end
    
    output << ""
    output << "="*70
    output << "💡 Fix all issues above, then re-run the accessibility checks"
    output << "="*70
    output << ""
    
    output.join("\n")
  end

  # Format all collected warnings with summary at top and details at bottom (same format as errors)
  def format_all_warnings(warnings)
    return "" if warnings.empty?
    
    timestamp = format_timestamp_for_terminal
    
    output = []
    output << "\n" + "="*70
    output << "⚠️  ACCESSIBILITY WARNINGS FOUND: #{warnings.length} warning(s) • #{timestamp}"
    output << "="*70
    output << ""
    output << "📋 SUMMARY OF WARNINGS:"
    output << ""
    
    # Summary list at top
    warnings.each_with_index do |warning, index|
      warning_type = warning[:warning_type]
      page_context = warning[:page_context]
      element_context = warning[:element_context]
      
      # Build summary line - prioritize view file
      summary = "   #{index + 1}. #{warning_type}"
      
      # Add view file prominently first
      if page_context[:view_file]
        summary += "\n      📝 File: #{page_context[:view_file]}"
      end
      
      # Add element identifier if available
      if element_context[:id].present?
        summary += "\n      🔍 Element: [id: #{element_context[:id]}]"
      elsif element_context[:href].present?
        href_display = element_context[:href].length > 40 ? "#{element_context[:href][0..37]}..." : element_context[:href]
        summary += "\n      🔍 Element: [href: #{href_display}]"
      elsif element_context[:src].present?
        src_display = element_context[:src].length > 40 ? "#{element_context[:src][0..37]}..." : element_context[:src]
        summary += "\n      🔍 Element: [src: #{src_display}]"
      end
      
      # Add path as fallback if no view file
      if !page_context[:view_file] && page_context[:path]
        summary += "\n      🔗 Path: #{page_context[:path]}"
      end
      
      output << summary
    end
    
    output << ""
    output << "="*70
    output << "📝 DETAILED WARNING DESCRIPTIONS:"
    output << "="*70
    output << ""
    
    # Detailed descriptions at bottom
    warnings.each_with_index do |warning, index|
      output << "\n" + "-"*70
      output << "WARNING #{index + 1} of #{warnings.length}:"
      output << "-"*70
      output << warning[:message]
    end
    
    output << ""
    output << "="*70
    output << "💡 Consider addressing these warnings to improve accessibility"
    output << "="*70
    output << ""
    
    output.join("\n")
  end

  # Build comprehensive error message
  # @param error_type [String] Type of accessibility error
  # @param element_context [Hash] Context about the element with the issue
  # @param page_context [Hash] Context about the page being tested
  # @return [String] Formatted error message
  def build_error_message(error_type, element_context, page_context)
    # Check config for show_fixes setting
    show_fixes = true
    begin
      require 'rails_accessibility_testing/config/yaml_loader'
      profile = defined?(Rails) && Rails.env.test? ? :test : :development
      config = RailsAccessibilityTesting::Config::YamlLoader.load(profile: profile)
      summary_config = config['summary'] || {}
      show_fixes = summary_config.fetch('show_fixes', true)
    rescue StandardError
      # Use default if config can't be loaded
    end
    
    RailsAccessibilityTesting::ErrorMessageBuilder.build(
      error_type: error_type,
      element_context: element_context,
      page_context: page_context,
      show_fixes: show_fixes
    )
  end

  # Build specific error title for interactive elements (links/buttons)
  # @param tag [String] HTML tag name (a, button, etc.)
  # @param element_context [Hash] Context about the element
  # @return [String] Specific error title
  def build_interactive_element_error_title(tag, element_context)
    # Use semantic terms instead of tag names
    semantic_name = case tag
                    when 'a'
                      'link'
                    when 'button'
                      'button'
                    else
                      "#{tag} element"
                    end
    
    base_title = "#{semantic_name.capitalize} missing accessible name"
    
    # Add specific identifying information
    details = []
    
    if tag == 'a' && element_context[:href].present?
      # For links, include the href
      href = element_context[:href]
      # Truncate long URLs for readability
      href_display = href.length > 50 ? "#{href[0..47]}..." : href
      details << "href: #{href_display}"
    end
    
    if element_context[:id].present?
      details << "id: #{element_context[:id]}"
    elsif element_context[:classes].present?
      # Use first class if no ID
      first_class = element_context[:classes].split(' ').first
      details << "class: #{first_class}" if first_class
    end
    
    if details.any?
      "#{base_title} (#{details.join(', ')})"
    else
      base_title
    end
  end

  # Determine likely view file based on Rails path and element context
  def determine_view_file(path, url, element_context = nil)
    return nil unless path
    
    clean_path = path.split('?').first.split('#').first
    
    # Get route info from Rails (most accurate)
    if defined?(Rails) && Rails.application
      begin
        route = Rails.application.routes.recognize_path(clean_path)
        controller = route[:controller]
        action = route[:action]
        
        # Try to find the exact view file
        view_file = find_view_file_for_controller_action(controller, action)
        
        # If we found the view file, check for partials that might contain the element
        if view_file && element_context
          # Scan the view file for rendered partials
          partials_in_view = find_partials_in_view_file(view_file)
          
          # Check if element matches any partial in the view
          partial_file = find_partial_for_element_in_list(controller, element_context, partials_in_view)
          return partial_file if partial_file
        end
        
        # If element might be in a partial or layout, check those too
        if element_context
          # Check if element is likely in a layout (navbar, footer, etc.)
          if element_in_layout?(element_context)
            layout_file = find_layout_file
            return layout_file if layout_file
            
            # Also check layout partials
            layout_partial = find_partial_in_layouts(element_context)
            return layout_partial if layout_partial
          end
          
          # Check if element is in a partial based on context
          partial_file = find_partial_for_element(controller, element_context)
          return partial_file if partial_file
        end
        
        return view_file if view_file
      rescue StandardError => e
        # Fall through to path-based detection
      end
    end
    
    # Fallback: path-based detection
    if clean_path.match?(/\A\//)
      parts = clean_path.sub(/\A\//, '').split('/').reject(&:empty?)
      
      if parts.empty? || clean_path == '/'
        # Root path - try common locations
        return find_view_file_for_controller_action('home', 'about') ||
               find_view_file_for_controller_action('home', 'index') ||
               find_view_file_for_controller_action('pages', 'home')
      elsif parts.length >= 2
        controller = parts[0..-2].join('/')
        action = parts.last
        return find_view_file_for_controller_action(controller, action)
      elsif parts.length == 1
        return find_view_file_for_controller_action(parts[0], 'index')
      end
    end
    
    nil
  end

  # Find view file for controller and action
  # Handles cases where action name doesn't match view file name (e.g., search action -> search_result.html.erb)
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
      
      # Last resort: check if there's only one view file in the controller directory
      # (common for single-action controllers or when action name is very different)
      all_views = extensions.flat_map { |ext| Dir.glob("#{controller_path}/*.html.#{ext}") }
      if all_views.length == 1
        return all_views.first
      end
    end
    
    nil
  end

  # Check if element is likely in a layout (navbar, footer, etc.)
  def element_in_layout?(element_context)
    return false unless element_context
    
    # Check parent context for layout indicators
    parent = element_context[:parent]
    return false unless parent
    
    # Common layout class/id patterns
    layout_indicators = ['navbar', 'nav', 'footer', 'header', 'main-nav', 'sidebar']
    
    classes = parent[:classes].to_s.downcase
    id = parent[:id].to_s.downcase
    
    layout_indicators.any? { |indicator| classes.include?(indicator) || id.include?(indicator) }
  end

  # Find layout file
  def find_layout_file
    extensions = %w[erb haml slim]
    
    # Check common layout files
    layout_names = ['application', 'main', 'default']
    
    layout_names.each do |layout_name|
      extensions.each do |ext|
        layout_path = "app/views/layouts/#{layout_name}.html.#{ext}"
        return layout_path if File.exist?(layout_path)
      end
    end
    
    # Check for any layout file
    extensions.each do |ext|
      layout_files = Dir.glob("app/views/layouts/*.html.#{ext}")
      return layout_files.first if layout_files.any?
    end
    
    nil
  end

  # Find partial file that might contain the element
  def find_partial_for_element(controller, element_context)
    return nil unless element_context
    
    extensions = %w[erb haml slim]
    
    # Check for common partial names based on element context
    id = element_context[:id].to_s
    classes = element_context[:classes].to_s
    
    # Try to match partial names from element attributes
    partial_names = []
    
    # Extract potential partial names from IDs/classes
    if id.present?
      # e.g., "navbar" from id="navbar" or class="navbar"
      partial_names << id.split('-').first
      partial_names << id.split('_').first
      partial_names << id  # Also try the full ID
    end
    
    if classes.present?
      classes.split(/\s+/).each do |cls|
        partial_names << cls.split('-').first
        partial_names << cls.split('_').first
        partial_names << cls  # Also try the full class name
      end
    end
    
    # Check partials in controller directory, shared, and layouts
    partial_names.uniq.each do |partial_name|
      next if partial_name.blank?
      
      extensions.each do |ext|
        partial_paths = [
          "app/views/#{controller}/_#{partial_name}.html.#{ext}",
          "app/views/shared/_#{partial_name}.html.#{ext}",
          "app/views/layouts/_#{partial_name}.html.#{ext}",
          "app/views/#{controller}/#{partial_name}.html.#{ext}",  # Sometimes partials don't have underscore
          "app/views/shared/#{partial_name}.html.#{ext}"
        ]
        
        found = partial_paths.find { |pp| File.exist?(pp) }
        return found if found
      end
    end
    
    nil
  end
  
  # Find partial in layouts directory based on element context
  def find_partial_in_layouts(element_context)
    return nil unless element_context
    
    extensions = %w[erb haml slim]
    id = element_context[:id].to_s
    classes = element_context[:classes].to_s
    
    # Common layout partial names
    partial_names = []
    partial_names << id.split('-').first if id.present?
    partial_names << id.split('_').first if id.present?
    
    if classes.present?
      classes.split(/\s+/).each do |cls|
        partial_names << cls.split('-').first
        partial_names << cls.split('_').first
      end
    end
    
    # Check all partials in layouts directory
    extensions.each do |ext|
      # First try specific names
      partial_names.uniq.each do |partial_name|
        next if partial_name.blank?
        partial_path = "app/views/layouts/_#{partial_name}.html.#{ext}"
        return partial_path if File.exist?(partial_path)
      end
      
      # If no match, scan all layout partials and try to match by content
      layout_partials = Dir.glob("app/views/layouts/_*.html.#{ext}")
      # Could add content-based matching here if needed
    end
    
    nil
  end

  # Check that form inputs have associated labels
  def check_form_labels
    page_context = get_page_context
    
    page.all('input[type="text"], input[type="email"], input[type="password"], input[type="number"], input[type="tel"], input[type="url"], input[type="search"], input[type="date"], input[type="time"], input[type="datetime-local"], textarea, select').each do |input|
      id = input[:id]
      next if id.blank?

      has_label = page.has_css?("label[for='#{id}']", wait: false)
      aria_label = input[:"aria-label"].present?
      aria_labelledby = input[:"aria-labelledby"].present?
      
      unless has_label || aria_label || aria_labelledby
        element_context = get_element_context(input)
        element_context[:input_type] = input[:type] || input.tag_name
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Form input missing label",
          element_context,
          page_context
        )
      end
    end
  end

  # Check that images have alt text
  def check_image_alt_text
    # Check all images, including hidden ones
    # Rails' image_tag helper generates <img> tags, so this will catch all images
    page.all('img', visible: :all).each do |img|
      # Check if alt attribute exists in the HTML
      # Use JavaScript hasAttribute which is the most reliable way to check
      # Use native attribute access instead of JavaScript evaluation for better performance
      has_alt_attribute = img.native.attribute('alt') != nil rescue false
      
      # If alt attribute doesn't exist, that's an error
      # If it exists but is empty (alt=""), that's valid for decorative images
      if has_alt_attribute == false
        element_context = get_element_context(img)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Image missing alt attribute",
          element_context,
          page_context
        )
      end
    end
  end

  # Check that buttons and links have accessible names
  def check_interactive_elements_have_names
    page.all('button, a[href], [role="button"], [role="link"]').each do |element|
      next unless element.visible?

      text = element.text.strip
      aria_label = element[:"aria-label"]
      aria_labelledby = element[:"aria-labelledby"]
      title = element[:title]

      # Check if element contains an image with alt text (common pattern for logo links)
      has_image_with_alt = false
      if text.blank?
        images = element.all('img', visible: :all)
        has_image_with_alt = images.any? do |img|
          alt = img[:alt]
          alt.present? && !alt.strip.empty?
        end
      end

      if text.blank? && aria_label.blank? && aria_labelledby.blank? && title.blank? && !has_image_with_alt
        element_context = get_element_context(element)
        tag = element.tag_name
        
        # Build more specific error title
        error_title = build_interactive_element_error_title(tag, element_context)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          error_title,
          element_context,
          page_context
        )
      end
    end
  end

  # Check for proper heading hierarchy
  def check_heading_hierarchy
    page_context = get_page_context
    headings = page.all('h1, h2, h3, h4, h5, h6', visible: true)
    
    if headings.empty?
      element_context = {
        tag: 'page',
        id: nil,
        classes: nil,
        href: nil,
        src: nil,
        text: 'Page has no visible headings',
        parent: nil
      }
      collect_warning("Page has no visible headings - consider adding at least an h1", element_context, page_context)
      return
    end

    h1_count = headings.count { |h| h.tag_name == 'h1' }
    first_heading = headings.first
    first_heading_level = first_heading ? first_heading.tag_name[1].to_i : nil
    
    if h1_count == 0
      # If the first heading is h2 or higher, provide a more specific message
      if first_heading_level && first_heading_level >= 2
        element_context = get_element_context(first_heading)
        collect_error(
          "Page has h#{first_heading_level} but no h1 heading",
          element_context,
          page_context
        )
      else
      # Create element context for page-level issue
      element_context = {
        tag: 'page',
        id: nil,
        classes: nil,
        href: nil,
        src: nil,
        text: 'Page has no H1 heading',
        parent: nil
      }
      
      collect_error(
        "Page missing H1 heading",
        element_context,
        page_context
      )
      end
    elsif h1_count > 1
      # Find all h1 elements to provide context
      h1_elements = headings.select { |h| h.tag_name == 'h1' }
      
      # Report error for each h1 after the first one
      h1_elements[1..-1].each do |h1|
        element_context = get_element_context(h1)
        page_context = get_page_context(element_context)
        
        collect_error(
          "Page has multiple h1 headings (#{h1_count} total) - only one h1 should be used per page",
          element_context,
          page_context
        )
      end
    end

    previous_level = 0
    headings.each do |heading|
      current_level = heading.tag_name[1].to_i
      if current_level > previous_level + 1
        element_context = get_element_context(heading)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Heading hierarchy skipped (h#{previous_level} to h#{current_level})",
          element_context,
          page_context
        )
      end
      previous_level = current_level
    end
  end

  # Check that focusable elements are keyboard accessible
  def check_keyboard_accessibility
    page_context = get_page_context
    modals = page.all('[role="dialog"], [role="alertdialog"]', visible: true)
    
    modals.each do |modal|
      focusable = modal.all('button, a, input, textarea, select, [tabindex]:not([tabindex="-1"])', visible: true)
      if focusable.empty?
        element_context = get_element_context(modal)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Modal dialog has no focusable elements",
          element_context,
          page_context
        )
      end
    end
  end

  # Check for proper ARIA landmarks
  def check_aria_landmarks
    page_context = get_page_context
    landmarks = page.all('main, nav, [role="main"], [role="navigation"], [role="banner"], [role="contentinfo"], [role="complementary"], [role="search"]', visible: true)
    
    if landmarks.empty?
      element_context = {
        tag: 'page',
        id: nil,
        classes: nil,
        href: nil,
        src: nil,
        text: 'Page has no ARIA landmarks',
        parent: nil
      }
      collect_warning("Page has no ARIA landmarks - consider adding <main> and <nav> elements", element_context, page_context)
    end
    
    # Check for main landmark
    main_landmarks = page.all('main, [role="main"]', visible: true)
    if main_landmarks.empty?
      # Create element context for page-level issue
      element_context = {
        tag: 'page',
        id: nil,
        classes: nil,
        href: nil,
        src: nil,
        text: 'Page has no MAIN landmark',
        parent: nil
      }
      
      collect_error(
        "Page missing MAIN landmark",
        element_context,
        page_context
      )
    end
  end

  # Check for skip links
  def check_skip_links
    page_context = get_page_context
    
    # Look for skip links with various common patterns:
    # - href="#main", "#maincontent", "#main-content", "#content", etc.
    # - class="skip-link", "skiplink", "skip_link", or any class containing "skip"
    # - text content containing "skip" (case-insensitive)
    skip_link_selectors = [
      'a[href="#main"]',
      'a[href*="main"]',  # Contains "main" (covers #maincontent, #main-content, etc.)
      'a[href^="#content"]',
      'a[class*="skip"]',  # Any class containing "skip" (covers skip-link, skiplink, skip_link)
      'a.skip-link',
      'a.skiplink',
      'a.skip_link'
    ]
    
    skip_links = page.all(skip_link_selectors.join(', '), visible: false)
    
    # Also check for links with "skip" in their text content
    if skip_links.empty?
      all_links = page.all('a', visible: false)
      skip_links = all_links.select do |link|
        link_text = link.text.to_s.downcase
        href = link[:href].to_s.downcase
        (link_text.include?('skip') && (href.include?('main') || href.include?('content'))) ||
        (link[:class].to_s.downcase.include?('skip') && (href.include?('main') || href.include?('content')))
      end
    end
    
    if skip_links.empty?
      element_context = {
        tag: 'page',
        id: nil,
        classes: nil,
        href: nil,
        src: nil,
        text: 'Page missing skip link',
        parent: nil
      }
      collect_warning("Page missing skip link - consider adding 'skip to main content' link", element_context, page_context)
    end
  end

  # Check form error messages are associated
  def check_form_error_associations
    page_context = get_page_context
    
    page.all('.field_with_errors input, .field_with_errors textarea, .field_with_errors select, .is-invalid, [aria-invalid="true"]').each do |input|
      id = input[:id]
      next if id.blank?

      has_error_message = page.has_css?("[aria-describedby*='#{id}'], .field_with_errors label[for='#{id}'] + .error, .field_with_errors label[for='#{id}'] + .invalid-feedback", wait: false)
      
      unless has_error_message
        element_context = get_element_context(input)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Form input error message not associated",
          element_context,
          page_context
        )
      end
    end
  end

  # Check for proper table structure
  def check_table_structure
    page_context = get_page_context
    
    page.all('table').each do |table|
      has_headers = table.all('th').any?
      has_caption = table.all('caption').any?
      
      if !has_headers
        element_context = get_element_context(table)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Table missing headers",
          element_context,
          page_context
        )
      end
    end
  end

  # Check custom elements (like trix-editor, web components) have proper labels
  def check_custom_element_labels(selector)
    page_context = get_page_context
    
    page.all(selector).each do |element|
      id = element[:id]
      next if id.blank?

      has_label = page.has_css?("label[for='#{id}']", wait: false)
      aria_label = element[:"aria-label"].present?
      aria_labelledby = element[:"aria-labelledby"].present?
      
      unless has_label || aria_label || aria_labelledby
        element_context = get_element_context(element)
        # Get page context with element context to find exact view file
        page_context = get_page_context(element_context)
        
        collect_error(
          "Custom element '#{selector}' missing label",
          element_context,
          page_context
        )
      end
    end
  end

  # Check for duplicate IDs
  def check_duplicate_ids
    page_context = get_page_context
    all_ids = page.all('[id]').map { |el| el[:id] }.compact
    duplicates = all_ids.group_by(&:itself).select { |k, v| v.length > 1 }.keys
    
    if duplicates.any?
      # Get first occurrence of first duplicate ID for element context
      first_duplicate_id = duplicates.first
      first_element = page.first("[id='#{first_duplicate_id}']", wait: false)
      
      element_context = if first_element
        ctx = get_element_context(first_element)
        ctx[:duplicate_ids] = duplicates
        ctx
      else
        {
          tag: 'multiple',
          id: first_duplicate_id,
          classes: nil,
          href: nil,
          src: nil,
          text: "Found #{duplicates.length} duplicate ID(s)",
          parent: nil,
          duplicate_ids: duplicates
        }
      end
      
      # Get page context with element context to find exact view file
      page_context = get_page_context(element_context)
      
      collect_error(
        "Duplicate IDs found",
        element_context,
        page_context
      )
    end
  end
end
end
