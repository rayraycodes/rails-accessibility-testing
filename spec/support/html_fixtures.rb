# frozen_string_literal: true

# HTML fixtures for testing accessibility checks
# Provides common HTML patterns for positive and negative test cases

module HtmlFixtures
  # Valid HTML patterns that should NOT trigger violations
  module Valid
    IMAGE_WITH_ALT = <<~HTML
      <html>
        <body>
          <img src="logo.png" alt="Company Logo">
        </body>
      </html>
    HTML

    IMAGE_DECORATIVE = <<~HTML
      <html>
        <body>
          <img src="decoration.png" alt="">
        </body>
      </html>
    HTML

    FORM_WITH_LABEL = <<~HTML
      <html>
        <body>
          <label for="email">Email</label>
          <input type="email" id="email" name="email">
        </body>
      </html>
    HTML

    FORM_WITH_ARIA_LABEL = <<~HTML
      <html>
        <body>
          <input type="text" id="name" aria-label="Full Name">
        </body>
      </html>
    HTML

    FORM_WITH_ARIA_LABELLEDBY = <<~HTML
      <html>
        <body>
          <span id="name-label">Full Name</span>
          <input type="text" id="name" aria-labelledby="name-label">
        </body>
      </html>
    HTML

    VALID_HEADING_HIERARCHY = <<~HTML
      <html>
        <body>
          <h1>Main Title</h1>
          <h2>Section</h2>
          <h3>Subsection</h3>
          <h2>Another Section</h2>
        </body>
      </html>
    HTML

    LINK_WITH_TEXT = <<~HTML
      <html>
        <body>
          <a href="/about">About Us</a>
        </body>
      </html>
    HTML

    LINK_WITH_ARIA_LABEL = <<~HTML
      <html>
        <body>
          <a href="/home" aria-label="Go to home page">
            <i class="icon-home"></i>
          </a>
        </body>
      </html>
    HTML

    BUTTON_WITH_TEXT = <<~HTML
      <html>
        <body>
          <button>Submit</button>
        </body>
      </html>
    HTML

    MODAL_WITH_FOCUSABLE = <<~HTML
      <html>
        <body>
          <div role="dialog">
            <button>Close</button>
            <input type="text">
          </div>
        </body>
      </html>
    HTML

    MAIN_LANDMARK = <<~HTML
      <html>
        <body>
          <main>
            <h1>Content</h1>
          </main>
        </body>
      </html>
    HTML

    TABLE_WITH_HEADERS = <<~HTML
      <html>
        <body>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>John</td>
                <td>john@example.com</td>
              </tr>
            </tbody>
          </table>
        </body>
      </html>
    HTML

    FORM_ERROR_ASSOCIATED = <<~HTML
      <html>
        <body>
          <input type="text" id="email" aria-invalid="true" aria-describedby="email-error">
          <div id="email-error" class="error">Email is required</div>
        </body>
      </html>
    HTML

    UNIQUE_IDS = <<~HTML
      <html>
        <body>
          <div id="content">Content</div>
          <div id="sidebar">Sidebar</div>
        </body>
      </html>
    HTML

    SKIP_LINK = <<~HTML
      <html>
        <body>
          <a href="#main-content" class="skip-link">Skip to main content</a>
          <main id="main-content">
            <h1>Content</h1>
          </main>
        </body>
      </html>
    HTML
  end

  # Invalid HTML patterns that SHOULD trigger violations
  module Invalid
    IMAGE_WITHOUT_ALT = <<~HTML
      <html>
        <body>
          <img src="logo.png">
        </body>
      </html>
    HTML

    FORM_WITHOUT_LABEL = <<~HTML
      <html>
        <body>
          <input type="email" id="email" name="email">
        </body>
      </html>
    HTML

    MISSING_H1 = <<~HTML
      <html>
        <body>
          <h2>Section</h2>
          <h3>Subsection</h3>
        </body>
      </html>
    HTML

    SKIPPED_HEADING_LEVEL = <<~HTML
      <html>
        <body>
          <h1>Main Title</h1>
          <h3>Skipped h2</h3>
        </body>
      </html>
    HTML

    LINK_WITHOUT_TEXT = <<~HTML
      <html>
        <body>
          <a href="/about"></a>
        </body>
      </html>
    HTML

    BUTTON_WITHOUT_TEXT = <<~HTML
      <html>
        <body>
          <button></button>
        </body>
      </html>
    HTML

    MODAL_WITHOUT_FOCUSABLE = <<~HTML
      <html>
        <body>
          <div role="dialog">
            <p>Modal content</p>
          </div>
        </body>
      </html>
    HTML

    MISSING_MAIN_LANDMARK = <<~HTML
      <html>
        <body>
          <h1>Content</h1>
        </body>
      </html>
    HTML

    TABLE_WITHOUT_HEADERS = <<~HTML
      <html>
        <body>
          <table>
            <tr>
              <td>Name</td>
              <td>Email</td>
            </tr>
          </table>
        </body>
      </html>
    HTML

    FORM_ERROR_NOT_ASSOCIATED = <<~HTML
      <html>
        <body>
          <input type="text" id="email" aria-invalid="true">
          <div class="error">Email is required</div>
        </body>
      </html>
    HTML

    DUPLICATE_IDS = <<~HTML
      <html>
        <body>
          <div id="content">Content 1</div>
          <div id="content">Content 2</div>
        </body>
      </html>
    HTML
  end

  # Edge case HTML patterns
  module EdgeCases
    HIDDEN_IMAGE = <<~HTML
      <html>
        <body>
          <img src="logo.png" alt="Logo" style="display: none;">
        </body>
      </html>
    HTML

    WRAPPED_LABEL = <<~HTML
      <html>
        <body>
          <label>
            Email
            <input type="email" name="email">
          </label>
        </body>
      </html>
    HTML

    RADIO_GROUP = <<~HTML
      <html>
        <body>
          <fieldset>
            <legend>Choose option</legend>
            <input type="radio" id="opt1" name="option" value="1">
            <label for="opt1">Option 1</label>
            <input type="radio" id="opt2" name="option" value="2">
            <label for="opt2">Option 2</label>
          </fieldset>
        </body>
      </html>
    HTML

    MULTIPLE_H1 = <<~HTML
      <html>
        <body>
          <h1>First H1</h1>
          <h1>Second H1</h1>
        </body>
      </html>
    HTML

    ICON_ONLY_BUTTON = <<~HTML
      <html>
        <body>
          <button aria-label="Close dialog">
            <i class="icon-close"></i>
          </button>
        </body>
      </html>
    HTML

    VISUALLY_HIDDEN_TEXT = <<~HTML
      <html>
        <head>
          <style>
            .visually-hidden { position: absolute; left: -10000px; }
          </style>
        </head>
        <body>
          <a href="/about">
            <i class="icon"></i>
            <span class="visually-hidden">About Us</span>
          </a>
        </body>
      </html>
    HTML
  end
end

RSpec.configure do |config|
  config.include HtmlFixtures
end

