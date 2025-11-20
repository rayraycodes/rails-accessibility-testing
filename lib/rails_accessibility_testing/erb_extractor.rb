# frozen_string_literal: true

module RailsAccessibilityTesting
  # Extracts HTML from ERB templates by converting Rails helpers to HTML
  # This allows static analysis of view files without rendering them
  #
  # @api private
  class ErbExtractor
    # Convert ERB template to HTML for static analysis
    # @param content [String] ERB template content
    # @return [String] Extracted HTML
    def self.extract_html(content)
      new(content).extract
    end

    def initialize(content)
      @content = content.dup
    end

    def extract
      convert_rails_helpers
      remove_erb_tags
      cleanup_whitespace
      @content
    end

    private

    # Convert Rails helpers to placeholder HTML
    def convert_rails_helpers
      convert_form_helpers
      convert_image_helpers
      convert_link_helpers
      convert_button_helpers
    end

    # Convert form field helpers
    def convert_form_helpers
      # select_tag "name", options, id: "custom_id" or select_tag "name"
      @content.gsub!(/<%=\s*select_tag\s+["']?(\w+)["']?[^%]*%>/) do |match|
        name = $1
        # Try to extract id from the match if present
        id_match = match.match(/id:\s*["']([^"']+)["']/) || match.match(/id:\s*:(\w+)/)
        id = id_match ? id_match[1] : name
        "<select name=\"#{name}\" id=\"#{id}\"></select>"
      end

      # text_field_tag "name"
      @content.gsub!(/<%=\s*text_field_tag\s+["']?(\w+)["']?[^%]*%>/) do
        name = $1
        "<input type=\"text\" name=\"#{name}\" id=\"#{name}\">"
      end

      # password_field_tag "name"
      @content.gsub!(/<%=\s*password_field_tag\s+["']?(\w+)["']?[^%]*%>/) do
        name = $1
        "<input type=\"password\" name=\"#{name}\" id=\"#{name}\">"
      end

      # email_field_tag "name"
      @content.gsub!(/<%=\s*email_field_tag\s+["']?(\w+)["']?[^%]*%>/) do
        name = $1
        "<input type=\"email\" name=\"#{name}\" id=\"#{name}\">"
      end

      # text_area_tag "name"
      @content.gsub!(/<%=\s*text_area_tag\s+["']?(\w+)["']?[^%]*%>/) do
        name = $1
        "<textarea name=\"#{name}\" id=\"#{name}\"></textarea>"
      end

      # f.submit "text"
      @content.gsub!(/<%=\s*f\.submit\s+["']([^"']+)["'][^%]*%>/) do
        text = $1
        "<input type=\"submit\" value=\"#{text}\">"
      end
    end

    # Convert image helpers
    def convert_image_helpers
      # image_tag "path"
      @content.gsub!(/<%=\s*image_tag\s+["']([^"']+)["'][^%]*%>/) do
        src = $1
        "<img src=\"#{src}\">"
      end
    end

    # Convert link helpers
    def convert_link_helpers
      # link_to with block (do...end) - might have content, might be empty
      @content.gsub!(/<%=\s*link_to\s+[^%]+do[^%]*%>.*?<%[\s]*end[\s]*%>/m) do |match|
        # Check if block has visible content (text or images)
        has_content = match.match?(/[^<%>]{3,}/) # At least 3 non-tag characters
        has_content ? "<a href=\"#\">content</a>" : "<a href=\"#\"></a>"
      end

      # link_to "text", path
      @content.gsub!(/<%=\s*link_to\s+["']([^"']+)["'],\s*[^%]+%>/) do
        text = $1
        "<a href=\"#\">#{text}</a>"
      end

      # link_to path, options (might be empty)
      @content.gsub!(/<%=\s*link_to\s+[^,]+,\s*[^%]+%>/) do
        "<a href=\"#\"></a>"
      end

      # link_to path (no text, no options)
      @content.gsub!(/<%=\s*link_to\s+[^,\s%]+%>/) do
        "<a href=\"#\"></a>"
      end
    end

    # Convert button helpers
    def convert_button_helpers
      # button_tag "text"
      @content.gsub!(/<%=\s*button_tag\s+["']([^"']+)["'][^%]*%>/) do
        text = $1
        "<button>#{text}</button>"
      end

      # button "text"
      @content.gsub!(/<%=\s*button\s+["']([^"']+)["'][^%]*%>/) do
        text = $1
        "<button>#{text}</button>"
      end
    end

    # Remove ERB tags
    def remove_erb_tags
      @content.gsub!(/<%[^%]*%>/, '')
      @content.gsub!(/<%=.*?%>/, '')
    end

    # Clean up extra whitespace
    def cleanup_whitespace
      @content.gsub!(/\n\s*\n\s*\n/, "\n\n")
    end
  end
end

