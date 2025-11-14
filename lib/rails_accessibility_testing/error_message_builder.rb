# frozen_string_literal: true

module RailsAccessibilityTesting
  # Builds formatted error messages for accessibility issues
  #
  # Formats comprehensive error messages with:
  # - Error type and header
  # - Page context (URL, path, view file)
  # - Element details (tag, id, classes, etc.)
  # - Specific remediation steps
  # - WCAG references
  #
  # @example
  #   ErrorMessageBuilder.build(
  #     error_type: "Image missing alt attribute",
  #     element_context: { tag: "img", src: "logo.png" },
  #     page_context: { url: "http://example.com", path: "/" }
  #   )
  #
  # @api private
  class ErrorMessageBuilder
    SEPARATOR = '=' * 70
    WCAG_REFERENCE = 'https://www.w3.org/WAI/WCAG21/Understanding/'

    class << self
      # Build a comprehensive error message
      # @param error_type [String] Type of accessibility error
      # @param element_context [Hash] Context about the element
      # @param page_context [Hash] Context about the page
      # @return [String] Formatted error message
      def build(error_type:, element_context:, page_context:)
        [
          header(error_type),
          page_info(page_context),
          element_info(element_context),
          remediation_section(error_type, element_context),
          footer
        ].compact.join("\n")
      end

      private

      def header(error_type)
        "\n#{SEPARATOR}\n❌ ACCESSIBILITY ERROR: #{error_type}\n#{SEPARATOR}\n"
      end

      def page_info(page_context)
        lines = [
          '📄 Page Being Tested:',
          "   URL: #{page_context[:url] || '(unknown)'}",
          "   Path: #{page_context[:path] || '(unknown)'}"
        ]

        if page_context[:view_file]
          lines << "   📝 Likely View File: #{page_context[:view_file]}"
        end

        lines.join("\n") + "\n"
      end

      def element_info(element_context)
        lines = ['📍 Element Details:']
        lines << "   Tag: <#{element_context[:tag]}>"
        lines << "   ID: #{element_context[:id] || '(none)'}"
        
        if element_context[:duplicate_ids] && element_context[:duplicate_ids].any?
          lines << "   Duplicate IDs: #{element_context[:duplicate_ids].join(', ')}"
        end
        
        lines << "   Classes: #{element_context[:classes] || '(none)'}"
        lines << "   Href: #{element_context[:href] || '(none)'}" if element_context[:href]
        lines << "   Src: #{element_context[:src] || '(none)'}" if element_context[:src]
        lines << "   Visible text: #{format_text(element_context[:text])}"

        if element_context[:parent]
          lines << format_parent(element_context[:parent])
        end

        lines.join("\n") + "\n"
      end

      def format_text(text)
        text.to_s.empty? ? '(empty)' : text
      end

      def format_parent(parent)
        parts = ["   Parent: <#{parent[:tag]}"]
        parts << " id=\"#{parent[:id]}\"" if parent[:id]
        parts << " class=\"#{parent[:classes]}\"" if parent[:classes]
        parts << '>'
        parts.join
      end

      def remediation_section(error_type, element_context)
        remediation = generate_remediation(error_type, element_context)
        "🔧 HOW TO FIX:\n#{remediation}\n"
      end

      def generate_remediation(error_type, element_context)
        # Extract base error type (remove details in parentheses for matching)
        base_error_type = error_type.to_s.split('(').first.strip
        
        case base_error_type
        when /Form input missing label/i
          form_input_remediation(element_context)
        when /Image missing alt attribute/i
          image_alt_remediation(element_context)
        when /^(Link|Button) missing accessible name/i
          interactive_element_remediation(error_type, element_context)
        when /Page missing H1 heading/i
          missing_h1_remediation
        when /Heading hierarchy skipped/i
          heading_hierarchy_remediation(error_type, element_context)
        when /Modal dialog has no focusable elements/i
          modal_remediation
        when /Page missing MAIN landmark/i
          missing_main_remediation
        when /Form input error message not associated/i
          form_error_remediation(element_context)
        when /Table missing headers/i
          table_remediation
        when /Custom element/i
          custom_element_remediation(error_type, element_context)
        when /Duplicate IDs found/i
          duplicate_ids_remediation(element_context)
        else
          # Fallback: try to match on key phrases even if format is slightly different
          case error_type.to_s
          when /missing.*label/i
            form_input_remediation(element_context)
          when /missing.*alt/i
            image_alt_remediation(element_context)
          when /missing.*accessible.*name/i
            interactive_element_remediation(error_type, element_context)
          when /missing.*H1/i
            missing_h1_remediation
          when /hierarchy.*skipped/i
            heading_hierarchy_remediation(error_type, element_context)
          when /modal.*focusable/i
            modal_remediation
          when /missing.*MAIN/i
            missing_main_remediation
          when /error.*message.*not.*associated/i
            form_error_remediation(element_context)
          when /table.*missing.*header/i
            table_remediation
          when /custom.*element/i
            custom_element_remediation(error_type, element_context)
          when /duplicate.*id/i
            duplicate_ids_remediation(element_context)
          else
            "   Please review the element details above and fix the accessibility issue."
          end
        end
      end

      def form_input_remediation(element_context)
        id = element_context[:id]
        input_type = element_context[:input_type] || 'text'
        
        remediation = "   Choose ONE of these solutions:\n\n"
        remediation += "   1. Add a <label> element:\n"
        remediation += "      <label for=\"#{id}\">Field Label</label>\n"
        remediation += "      <input type=\"#{input_type}\" id=\"#{id}\" name=\"field_name\">\n\n"
        remediation += "   2. Add  aria-label attribute:\n"
        remediation += "      <input type=\"#{input_type}\" id=\"#{id}\" aria-label=\"Field Label\">\n\n"
        remediation += "   3. Wrap input in label (Rails helper):\n"
        remediation += "      <%= label_tag :field_name, 'Field Label' %>\n"
        remediation += "      <%= text_field_tag :field_name, nil, id: '#{id}' %>\n\n"
        remediation += "   💡 Best Practice: Use <label> elements when possible.\n"
        remediation += "      They provide better UX (clicking label focuses input).\n"
        remediation
      end

      def image_alt_remediation(element_context)
        src = element_context[:src] || 'image.png'
        
        remediation = "   Choose ONE of these solutions:\n\n"
        remediation += "   1. Add alt text for informative images:\n"
        remediation += "      <img src=\"#{src}\" alt=\"Description of image\">\n\n"
        remediation += "   2. Add empty alt for decorative images:\n"
        remediation += "      <img src=\"#{src}\" alt=\"\">\n\n"
        remediation += "   3. Use Rails image_tag helper:\n"
        remediation += "      <%= image_tag 'image.png', alt: 'Description' %>\n\n"
        remediation += "   💡 Best Practice: All images must have alt attribute.\n"
        remediation += "      Use empty alt=\"\" only for purely decorative images.\n"
        remediation
      end

      def interactive_element_remediation(error_type, element_context)
        tag = element_context[:tag]
        
        remediation = "   Choose ONE of these solutions:\n\n"
        
        if tag == 'a'
          remediation += "   1. Add visible link text:\n"    
          remediation += "      <%= link_to 'Descriptive Link Text', path %>\n\n"
          remediation += "   2. Add aria-label (for icon-only links):\n"
          remediation += "      <%= link_to path, aria: { label: 'Descriptive action' } do %>\n"
          remediation += "        <i class='icon'></i>\n"
          remediation += "      <% end %>\n\n"
          remediation += "   3. Add visually hidden text:\n"
          remediation += "      <%= link_to path do %>\n"
          remediation += "        <i class='icon'></i>\n"
          remediation += "        <span class='visually-hidden'>Descriptive action</span>\n"
          remediation += "      <% end %>\n\n"
        else
          remediation += "   1. Add visible button text:\n"
          remediation += "      <button>Descriptive Button Text</button>\n\n"
          remediation += "   2. Add aria-label (for icon-only buttons):\n"
          remediation += "      <button aria-label='Descriptive action'>\n"
          remediation += "        <i class='icon'></i>\n"
          remediation += "      </button>\n\n"
        end
        
        remediation += "   💡 Best Practice: Use visible text when possible.\n"
        remediation += "      Use aria-label only for icon-only buttons/links.\n"
        remediation
      end

      def missing_h1_remediation
        remediation = "   Add an <h1> heading to your page:\n\n"
        remediation += "   <h1>Main Page Title</h1>\n\n"
        remediation += "   Or in Rails ERB:\n"
        remediation += "   <h1><%= @page_title || 'Default Title' %></h1>\n\n"
        remediation += "   💡 Best Practice: Every page should have exactly one <h1>.\n"
        remediation += "      It should describe the main purpose of the page.\n"
        remediation
      end

      def heading_hierarchy_remediation(error_type, element_context)
        # Extract heading levels from error_type: "HEADING hierarchy skipped (h1 to h3)"
        match = error_type.match(/h(\d+) to h(\d+)/)
        previous_level = match ? match[1].to_i : 1
        current_level = match ? match[2].to_i : 3
        
        remediation = "   Fix the heading hierarchy:\n\n"
        remediation += "   Current: <h#{previous_level}> ... <h#{current_level}>\n"
        remediation += "   Should be: <h#{previous_level}> ... <h#{previous_level + 1}>\n\n"
        remediation += "   Example:\n"
        remediation += "   <h#{previous_level}>Section Title</h#{previous_level}>\n"
        remediation += "   <h#{previous_level + 1}>Subsection Title</h#{previous_level + 1}>\n\n"
        remediation += "   💡 Best Practice: Don't skip heading levels.\n"
        remediation += "      Use h1 → h2 → h3 in order.\n"
        remediation
      end

      def modal_remediation
        remediation = "   Add focusable elements to the modal:\n\n"
        remediation += "   <div role=\"dialog\">\n"
        remediation += "     <button>Close</button>\n"
        remediation += "     <!-- Modal content -->\n"
        remediation += "   </div>\n\n"
        remediation += "   💡 Best Practice: Modals must have at least one focusable element.\n"
        remediation += "      Focus should be trapped within the modal when open.\n"
        remediation
      end

      def missing_main_remediation
        remediation = "   Wrap main content in <main> tag:\n\n"
        remediation += "   <main>\n"
        remediation += "     <!-- Main page content -->\n"
        remediation += "   </main>\n\n"
        remediation += "   Or in Rails ERB layout:\n"
        remediation += "   <main>\n"
        remediation += "     <%= yield %>\n"
        remediation += "   </main>\n\n"
        remediation += "   💡 Best Practice: Every page should have one <main> element.\n"
        remediation += "      It identifies the primary content area.\n"
        remediation
      end

      def form_error_remediation(element_context)
        id = element_context[:id]
        
        remediation = "   Associate error message with input:\n\n"
        remediation += "   1. Use aria-describedby:\n"
        remediation += "      <input id=\"#{id}\" aria-describedby=\"#{id}-error\" aria-invalid=\"true\">\n"
        remediation += "      <div id=\"#{id}-error\" class=\"error\">Error message</div>\n\n"
        remediation += "   2. Use Rails form helpers with error display:\n"
        remediation += "      <%= form_with model: @model do |f| %>\n"
        remediation += "        <%= f.label :field %>\n"
        remediation += "        <%= f.text_field :field, class: 'form-control', aria: { describedby: \"#{id}-error\" } %>\n"
        remediation += "        <%= f.error_message :field, class: 'error', id: \"#{id}-error\" %>\n"
        remediation += "      <% end %>\n\n"
        remediation += "   💡 Best Practice: Error messages must be associated with inputs.\n"
        remediation += "      Screen readers need to announce errors when they occur.\n"
        remediation
      end

      def table_remediation
        remediation = "   Add table headers:\n\n"
        remediation += "   <table>\n"
        remediation += "     <thead>\n"
        remediation += "       <tr>\n"
        remediation += "         <th>Column 1</th>\n"
        remediation += "         <th>Column 2</th>\n"
        remediation += "       </tr>\n"
        remediation += "     </thead>\n"
        remediation += "     <tbody>\n"
        remediation += "       <tr>\n"
        remediation += "         <td>Data 1</td>\n"
        remediation += "         <td>Data 2</td>\n"
        remediation += "       </tr>\n"
        remediation += "     </tbody>\n"
        remediation += "   </table>\n\n"
        remediation += "   💡 Best Practice: Tables must have <th> headers.\n"
        remediation += "      Use <caption> for table descriptions.\n"
        remediation
      end

      def custom_element_remediation(error_type, element_context)
        # Extract selector from error_type: "CUSTOM ELEMENT 'trix-editor' missing label"
        match = error_type.match(/CUSTOM ELEMENT '([^']+)'/)
        selector = match ? match[1] : 'custom-element'
        id = element_context[:id]
        
        remediation = "   Choose ONE of these solutions:\n\n"
        remediation += "   1. Add a <label> element:\n"
        remediation += "      <label for=\"#{id}\">#{selector} Label</label>\n"
        remediation += "      <#{selector} id=\"#{id}\"></#{selector}>\n\n"
        remediation += "   2. Add aria-label attribute:\n"
        remediation += "      <#{selector} id=\"#{id}\" aria-label=\"#{selector} Label\"></#{selector}>\n\n"
        remediation += "   💡 Best Practice: Custom elements need labels just like form inputs.\n"
        remediation
      end

      def duplicate_ids_remediation(element_context)
        duplicates = element_context[:duplicate_ids] || []
        
        remediation = "   Ensure each ID is unique on the page:\n\n"
        remediation += "   Duplicate IDs found:\n"
        duplicates.each { |id| remediation += "   - #{id}\n" }
        remediation += "\n"
        remediation += "   <!-- Bad -->\n"
        remediation += "   <div id=\"content\">...</div>\n"
        remediation += "   <div id=\"content\">...</div>\n\n"
        remediation += "   <!-- Good -->\n"
        remediation += "   <div id=\"main-content\">...</div>\n"
        remediation += "   <div id=\"sidebar-content\">...</div>\n\n"
        remediation += "   Or in Rails ERB, use unique IDs:\n"
        remediation += "   <div id=\"<%= dom_id(@item) %>\">...</div>\n\n"
        remediation += "   💡 Best Practice: IDs must be unique within a page.\n"
        remediation += "      Screen readers and JavaScript rely on unique IDs.\n"
        remediation
      end

      def footer
        "📖 WCAG Reference: #{WCAG_REFERENCE}\n#{SEPARATOR}"
      end
    end
  end
end

