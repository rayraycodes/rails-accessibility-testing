# frozen_string_literal: true

# False Positive Prevention Tests
# Ensures that common Rails patterns and valid accessibility patterns
# are NOT incorrectly flagged as violations.
#
# This is critical for developer experience - the gem should be low-noise
# and only flag actual accessibility issues.

require 'spec_helper'

RSpec.describe 'False Positive Prevention' do
  include HtmlFixtures

  describe 'Rails form helpers' do
    it 'does not flag Rails form_with helper output' do
      # Rails form_with generates proper label associations
      html = <<~HTML
        <html>
          <body>
            <form>
              <label for="user_email">Email</label>
              <input type="email" name="user[email]" id="user_email">
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag Rails fields_for nested forms' do
      html = <<~HTML
        <html>
          <body>
            <form>
              <label for="user_addresses_attributes_0_street">Street</label>
              <input type="text" name="user[addresses_attributes][0][street]" id="user_addresses_attributes_0_street">
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end
  end

  describe 'Rails link helpers' do
    it 'does not flag Rails link_to helper output' do
      html = <<~HTML
        <html>
          <body>
            <a href="/about">About Us</a>
            <a href="/contact" aria-label="Contact page">
              <i class="icon-mail"></i>
            </a>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::InteractiveElementsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag Rails button_to helper output' do
      html = <<~HTML
        <html>
          <body>
            <button type="submit">Save</button>
            <button type="button" aria-label="Close dialog">
              <i class="icon-close"></i>
            </button>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::InteractiveElementsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end
  end

  describe 'Rails image helpers' do
    it 'does not flag Rails image_tag helper output' do
      html = <<~HTML
        <html>
          <body>
            <img src="/assets/logo.png" alt="Company Logo">
            <img src="/assets/decoration.png" alt="">
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::ImageAltTextCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end
  end

  describe 'valid accessibility patterns' do
    it 'does not flag properly structured forms with fieldsets' do
      html = <<~HTML
        <html>
          <body>
            <form>
              <fieldset>
                <legend>Personal Information</legend>
                <label for="first_name">First Name</label>
                <input type="text" id="first_name" name="first_name">
                <label for="last_name">Last Name</label>
                <input type="text" id="last_name" name="last_name">
              </fieldset>
              <fieldset>
                <legend>Contact Information</legend>
                <label for="email">Email</label>
                <input type="email" id="email" name="email">
              </fieldset>
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag radio button groups with proper structure' do
      html = <<~HTML
        <html>
          <body>
            <fieldset>
              <legend>Choose an option</legend>
              <input type="radio" id="opt1" name="option" value="1">
              <label for="opt1">Option 1</label>
              <input type="radio" id="opt2" name="option" value="2">
              <label for="opt2">Option 2</label>
            </fieldset>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag checkbox groups with proper structure' do
      html = <<~HTML
        <html>
          <body>
            <fieldset>
              <legend>Select interests</legend>
              <input type="checkbox" id="interest1" name="interests[]" value="tech">
              <label for="interest1">Technology</label>
              <input type="checkbox" id="interest2" name="interests[]" value="design">
              <label for="interest2">Design</label>
            </fieldset>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag tables with proper structure' do
      html = <<~HTML
        <html>
          <body>
            <table>
              <caption>User Data</caption>
              <thead>
                <tr>
                  <th scope="col">Name</th>
                  <th scope="col">Email</th>
                  <th scope="col">Role</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th scope="row">John Doe</th>
                  <td>john@example.com</td>
                  <td>Admin</td>
                </tr>
              </tbody>
            </table>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::TableStructureCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag pages with proper ARIA landmarks' do
      html = <<~HTML
        <html>
          <body>
            <header role="banner">
              <nav role="navigation">
                <a href="/">Home</a>
              </nav>
            </header>
            <main role="main">
              <h1>Main Content</h1>
            </main>
            <aside role="complementary">
              <h2>Sidebar</h2>
            </aside>
            <footer role="contentinfo">
              <p>Copyright</p>
            </footer>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::AriaLandmarksCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end

    it 'does not flag pages with native HTML5 landmarks' do
      html = <<~HTML
        <html>
          <body>
            <header>
              <nav>
                <a href="/">Home</a>
              </nav>
            </header>
            <main>
              <h1>Main Content</h1>
            </main>
            <aside>
              <h2>Sidebar</h2>
            </aside>
            <footer>
              <p>Copyright</p>
            </footer>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::AriaLandmarksCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end
  end

  describe 'edge cases that should not be flagged' do
    it 'does not flag hidden form inputs' do
      html = <<~HTML
        <html>
          <body>
            <form>
              <input type="hidden" name="authenticity_token" value="token">
              <input type="text" id="visible" name="visible">
              <label for="visible">Visible Field</label>
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      # Hidden inputs are not in the selector, so should not be flagged
      expect(violations).to be_empty
    end

    it 'does not flag disabled form inputs' do
      html = <<~HTML
        <html>
          <body>
            <form>
              <label for="disabled_field">Disabled Field</label>
              <input type="text" id="disabled_field" name="disabled" disabled>
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      # Disabled inputs with labels should not be flagged
      expect(violations).to be_empty
    end

    it 'does not flag read-only form inputs' do
      html = <<~HTML
        <html>
          <body>
            <form>
              <label for="readonly_field">Read-only Field</label>
              <input type="text" id="readonly_field" name="readonly" readonly>
            </form>
          </body>
        </html>
      HTML

      app = CapybaraTestHelpers::TestApp.new(html)
      page = Capybara::Session.new(:rack_test, app)
      page.visit('/')

      check = RailsAccessibilityTesting::Checks::FormLabelsCheck.new(page: page, context: {})
      violations = check.check

      expect(violations).to be_empty
    end
  end
end

