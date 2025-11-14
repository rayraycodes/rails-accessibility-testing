# frozen_string_literal: true

# Accessibility helper methods for system specs
#
# Provides comprehensive accessibility checks with detailed error messages.
# This module is automatically included in all system specs when the gem is required.
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
module AccessibilityHelper
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
    
    check_form_labels
    check_image_alt_text
    check_interactive_elements_have_names
    check_heading_hierarchy
    check_keyboard_accessibility
    
    # If we collected any errors and this was called directly (not from comprehensive), raise them
    if @accessibility_errors.any? && !@in_comprehensive_check
      raise format_all_errors(@accessibility_errors)
    end
  end

  # Full comprehensive check - runs all 11 checks including advanced
  def check_comprehensive_accessibility
    @accessibility_errors = []
    @in_comprehensive_check = true
    
    check_basic_accessibility
    check_aria_landmarks
    check_form_error_associations
    check_table_structure
    check_duplicate_ids
    check_skip_links  # Warning only, not error
    
    @in_comprehensive_check = false
    
    # If we collected any errors, raise them all together
    if @accessibility_errors.any?
      raise format_all_errors(@accessibility_errors)
    end
  end

  private

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

  # Format all collected errors with summary at top and details at bottom
  def format_all_errors(errors)
    return "" if errors.empty?
    
    output = []
    output << "\n" + "="*70
    output << "❌ ACCESSIBILITY ERRORS FOUND: #{errors.length} issue(s)"
    output << "="*70
    output << ""
    output << "📋 SUMMARY OF ISSUES:"
    output << ""
    
    # Summary list at top
    errors.each_with_index do |error, index|
      error_type = error[:error_type]
      page_context = error[:page_context]
      element_context = error[:element_context]
      
      # Build summary line
      summary = "   #{index + 1}. #{error_type}"
      
      # Add location info
      if page_context[:view_file]
        summary += " (#{page_context[:view_file]})"
      end
      
      # Add element identifier if available
      if element_context[:id].present?
        summary += " [id: #{element_context[:id]}]"
      elsif element_context[:href].present?
        href_display = element_context[:href].length > 40 ? "#{element_context[:href][0..37]}..." : element_context[:href]
        summary += " [href: #{href_display}]"
      elsif element_context[:src].present?
        src_display = element_context[:src].length > 40 ? "#{element_context[:src][0..37]}..." : element_context[:src]
        summary += " [src: #{src_display}]"
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
    
    output.join("\n")
  end

  # Build comprehensive error message
  # @param error_type [String] Type of accessibility error
  # @param element_context [Hash] Context about the element with the issue
  # @param page_context [Hash] Context about the page being tested
  # @return [String] Formatted error message
  def build_error_message(error_type, element_context, page_context)
    RailsAccessibilityTesting::ErrorMessageBuilder.build(
      error_type: error_type,
      element_context: element_context,
      page_context: page_context
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
        
        # If element might be in a partial or layout, check those too
        if element_context
          # Check if element is likely in a layout (navbar, footer, etc.)
          if element_in_layout?(element_context)
            layout_file = find_layout_file
            return layout_file if layout_file
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
  def find_view_file_for_controller_action(controller, action)
    extensions = %w[erb haml slim]
    extensions.each do |ext|
      view_paths = [
        "app/views/#{controller}/#{action}.html.#{ext}",
        "app/views/#{controller}/_#{action}.html.#{ext}",
        "app/views/#{controller}/#{action}.#{ext}"
      ]
      
      found = view_paths.find { |vp| File.exist?(vp) }
      return found if found
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
    end
    
    if classes.present?
      classes.split(/\s+/).each do |cls|
        partial_names << cls.split('-').first
        partial_names << cls.split('_').first
      end
    end
    
    # Check partials in controller directory
    partial_names.uniq.each do |partial_name|
      next if partial_name.blank?
      
      extensions.each do |ext|
        partial_paths = [
          "app/views/#{controller}/_#{partial_name}.html.#{ext}",
          "app/views/shared/_#{partial_name}.html.#{ext}",
          "app/views/layouts/_#{partial_name}.html.#{ext}"
        ]
        
        found = partial_paths.find { |pp| File.exist?(pp) }
        return found if found
      end
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
      has_alt_attribute = page.evaluate_script("arguments[0].hasAttribute('alt')", img.native)
      
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

      if text.blank? && aria_label.blank? && aria_labelledby.blank? && title.blank?
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
      warn "⚠️  Page has no visible headings - consider adding at least an h1"
      return
    end

    h1_count = headings.count { |h| h.tag_name == 'h1' }
    if h1_count == 0
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
    elsif h1_count > 1
      warn "⚠️  Page has multiple h1 headings (#{h1_count}) - consider using only one"
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
      warn "⚠️  Page has no ARIA landmarks - consider adding <main> and <nav> elements"
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
    skip_links = page.all('a[href="#main"], a[href*="main-content"], a.skip-link, a[href^="#content"]', visible: false)
    
    if skip_links.empty?
      warn "⚠️  Page missing skip link - consider adding 'skip to main content' link"
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
