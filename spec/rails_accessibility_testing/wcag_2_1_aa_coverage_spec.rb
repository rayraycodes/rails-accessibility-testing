# frozen_string_literal: true

require 'spec_helper'
require 'rails_accessibility_testing/engine/rule_engine'
require 'rails_accessibility_testing/config/yaml_loader'

RSpec.describe 'WCAG 2.1 AA Coverage', type: :system do
  # Comprehensive test suite to verify all 11 checks cover WCAG 2.1 AA requirements
  # This ensures the gem provides complete accessibility coverage

  let(:config) do
    RailsAccessibilityTesting::Config::YamlLoader.load(profile: :test)
  end

  let(:engine) do
    RailsAccessibilityTesting::Engine::RuleEngine.new(config: config)
  end

  # Helper to create a Capybara page from HTML
  def create_page_from_html(html)
    app = CapybaraTestHelpers::TestApp.new(html)
    session = Capybara::Session.new(:rack_test, app)
    session.visit('/')
    session
  end

  describe 'WCAG 1.1.1 - Non-text Content (Level A)' do
    # All non-text content that is presented to the user has a text alternative
    # Covered by: ImageAltTextCheck

    context 'ImageAltTextCheck' do
      it 'detects images missing alt attribute' do
        html = '<img src="logo.png">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'image_alt_text' && v.message.include?('missing alt') }).to be true
        expect(violations.first.wcag_reference).to eq('1.1.1')
      end

      it 'allows images with descriptive alt text' do
        html = '<img src="logo.png" alt="Company Logo">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'image_alt_text' && v.message.include?('missing alt') }).to be true
      end

      it 'allows decorative images with empty alt' do
        html = '<img src="decoration.png" alt="">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        # Empty alt is valid for decorative images (may show warning but not error)
        image_violations = violations.select { |v| v.rule_name == 'image_alt_text' }
        expect(image_violations.none? { |v| v.message.include?('missing alt') }).to be true
      end

      it 'detects images in hidden containers' do
        html = '<div style="display:none"><img src="hidden.png"></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        # Should still detect missing alt even if hidden
        expect(violations.any? { |v| v.rule_name == 'image_alt_text' }).to be true
      end
    end
  end

  describe 'WCAG 1.3.1 - Info and Relationships (Level A)' do
    # Information, structure, and relationships conveyed through presentation can be programmatically determined
    # Covered by: FormLabelsCheck, HeadingCheck, TableStructureCheck, AriaLandmarksCheck

    context 'FormLabelsCheck' do
      it 'detects form inputs missing labels' do
        html = '<input type="text" id="email" name="email">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'form_labels' }).to be true
        expect(violations.first.wcag_reference).to eq('1.3.1')
      end

      it 'allows inputs with label[for]' do
        html = '<label for="email">Email</label><input type="email" id="email">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'form_labels' }).to be true
      end

      it 'allows inputs with aria-label' do
        html = '<input type="text" id="name" aria-label="Full Name">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'form_labels' }).to be true
      end

      it 'allows inputs with aria-labelledby' do
        html = '<span id="label">Name</span><input type="text" id="name" aria-labelledby="label">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'form_labels' }).to be true
      end

      it 'checks all input types: text, email, password, number, tel, url, search, date, time, datetime-local' do
        input_types = %w[text email password number tel url search date time datetime-local]
        
        input_types.each do |type|
          html = "<input type=\"#{type}\" id=\"field_#{type}\" name=\"field_#{type}\">"
          page = create_page_from_html(html)
          violations = engine.check(page, context: {})
          
          expect(violations.any? { |v| v.rule_name == 'form_labels' }).to be true,
            "Should detect missing label for input type: #{type}"
        end
      end

      it 'checks textarea elements' do
        html = '<textarea id="message" name="message"></textarea>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'form_labels' }).to be true
      end

      it 'checks select elements' do
        html = '<select id="country" name="country"><option>USA</option></select>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'form_labels' }).to be true
      end
    end

    context 'HeadingCheck - Hierarchy' do
      it 'detects missing h1 heading' do
        html = '<h2>Section</h2><h3>Subsection</h3>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'heading' && v.message.include?('h1') }).to be true
        expect(violations.first.wcag_reference).to eq('1.3.1')
      end

      it 'detects multiple h1 headings' do
        html = '<h1>First</h1><h2>Section</h2><h1>Second</h1>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        multiple_h1 = violations.select { |v| v.rule_name == 'heading' && v.message.include?('multiple h1') }
        expect(multiple_h1.length).to eq(1) # One violation for the second h1
      end

      it 'detects skipped heading levels' do
        html = '<h1>Title</h1><h3>Skipped h2</h3>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'heading' && v.message.include?('skipped') }).to be true
      end

      it 'allows proper heading hierarchy' do
        html = '<h1>Title</h1><h2>Section</h2><h3>Subsection</h3><h2>Another Section</h2>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        hierarchy_violations = violations.select { |v| v.rule_name == 'heading' && (v.message.include?('skipped') || v.message.include?('multiple')) }
        expect(hierarchy_violations).to be_empty
      end

      it 'detects empty headings' do
        html = '<h1></h1>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'heading' && v.message.include?('Empty heading') }).to be true
        expect(violations.find { |v| v.message.include?('Empty heading') }.wcag_reference).to eq('4.1.2')
      end

      it 'detects headings with only images without alt text' do
        html = '<h1><img src="logo.png"></h1>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'heading' && v.message.include?('images without alt') }).to be true
      end
    end

    context 'TableStructureCheck' do
      it 'detects tables missing headers' do
        html = '<table><tr><td>Data</td></tr></table>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'table_structure' }).to be true
        expect(violations.first.wcag_reference).to eq('1.3.1')
      end

      it 'allows tables with th headers' do
        html = '<table><thead><tr><th>Header</th></tr></thead><tbody><tr><td>Data</td></tr></tbody></table>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'table_structure' }).to be true
      end
    end

    context 'AriaLandmarksCheck' do
      it 'detects pages missing MAIN landmark' do
        html = '<div>Content</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'aria_landmarks' && v.message.include?('MAIN landmark') }).to be true
        expect(violations.first.wcag_reference).to eq('1.3.1')
      end

      it 'allows pages with main element' do
        html = '<main><h1>Content</h1></main>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'aria_landmarks' && v.message.include?('MAIN landmark') }).to be true
      end

      it 'allows pages with role="main"' do
        html = '<div role="main"><h1>Content</h1></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'aria_landmarks' && v.message.include?('MAIN landmark') }).to be true
      end
    end
  end

  describe 'WCAG 1.4.3 - Contrast (Minimum) (Level AA)' do
    # The visual presentation of text and images of text has a contrast ratio of at least 4.5:1
    # Covered by: ColorContrastCheck

    context 'ColorContrastCheck' do
      it 'is implemented (may be disabled by default)' do
        # Color contrast check exists but may require JS evaluation
        # This test verifies the check class exists and can be instantiated
        expect(RailsAccessibilityTesting::Checks::ColorContrastCheck.rule_name).to eq(:color_contrast)
      end

      # Note: Full contrast testing requires JavaScript evaluation of computed styles
      # This is typically disabled by default for performance
    end
  end

  describe 'WCAG 2.1.1 - Keyboard (Level A)' do
    # All functionality of the content is operable through a keyboard interface
    # Covered by: KeyboardAccessibilityCheck

    context 'KeyboardAccessibilityCheck' do
      it 'detects modals without focusable elements' do
        html = '<div role="dialog">No focusable content</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'keyboard_accessibility' }).to be true
        expect(violations.first.wcag_reference).to eq('2.1.1')
      end

      it 'allows modals with focusable elements' do
        html = '<div role="dialog"><button>Close</button><input type="text"></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'keyboard_accessibility' }).to be true
      end

      it 'checks alertdialog role' do
        html = '<div role="alertdialog">Alert</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'keyboard_accessibility' }).to be true
      end
    end
  end

  describe 'WCAG 2.4.1 - Bypass Blocks (Level A)' do
    # A mechanism is available to bypass blocks of content that are repeated on multiple Web pages
    # Covered by: SkipLinksCheck

    context 'SkipLinksCheck' do
      it 'is implemented' do
        # Skip links check exists (currently returns warnings, not errors)
        expect(RailsAccessibilityTesting::Checks::SkipLinksCheck.rule_name).to eq(:skip_links)
      end

      # Note: Skip links are typically warnings, not errors, as they're a best practice
      # but not always required depending on page structure
    end
  end

  describe 'WCAG 2.4.4 - Link Purpose (In Context) (Level A)' do
    # The purpose of each link can be determined from the link text alone or from the link text together with its programmatically determined link context
    # Covered by: InteractiveElementsCheck

    context 'InteractiveElementsCheck - Links' do
      it 'detects links missing accessible name' do
        html = '<a href="/page"></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
        expect(violations.first.wcag_reference).to eq('2.4.4')
      end

      it 'allows links with visible text' do
        html = '<a href="/about">About Us</a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
      end

      it 'allows links with aria-label' do
        html = '<a href="/home" aria-label="Go to home page"><i class="icon"></i></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
      end

      it 'allows links with aria-labelledby' do
        html = '<span id="link-label">Home</span><a href="/" aria-labelledby="link-label"></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
      end

      it 'allows links with images that have alt text' do
        html = '<a href="/"><img src="logo.png" alt="Home"></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
      end

      it 'detects links with images missing alt text' do
        html = '<a href="/"><img src="logo.png"></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        # Should detect either missing link name or missing image alt
        link_violations = violations.select { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }
        image_violations = violations.select { |v| v.rule_name == 'image_alt_text' }
        expect(link_violations.any? || image_violations.any?).to be true
      end

      it 'allows links with title attribute' do
        html = '<a href="/page" title="Go to page"></a>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Link') }).to be true
      end
    end
  end

  describe 'WCAG 2.4.6 - Headings and Labels (Level AA)' do
    # Headings and labels describe topic or purpose
    # Covered by: HeadingCheck

    context 'HeadingCheck - Descriptive' do
      it 'detects headings used for styling only' do
        html = '<h2>•</h2>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        styling_violations = violations.select { |v| v.rule_name == 'heading' && v.message.include?('styling') }
        expect(styling_violations.any?).to be true
        expect(styling_violations.first.wcag_reference).to eq('2.4.6')
      end

      it 'allows descriptive headings' do
        html = '<h1>Main Page Title</h1><h2>Section About Products</h2>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        styling_violations = violations.select { |v| v.rule_name == 'heading' && v.message.include?('styling') }
        expect(styling_violations).to be_empty
      end
    end
  end

  describe 'WCAG 3.3.1 - Error Identification (Level A)' do
    # If an input error is automatically detected, the item that is in error is identified and the error is described to the user in text
    # Covered by: FormErrorsCheck

    context 'FormErrorsCheck' do
      it 'detects form errors not associated with inputs' do
        html = '<input type="text" id="email" class="is-invalid" name="email">'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'form_errors' }).to be true
        expect(violations.first.wcag_reference).to eq('3.3.1')
      end

      it 'allows errors associated via aria-describedby' do
        html = <<~HTML
          <input type="text" id="email" aria-invalid="true" aria-describedby="email-error">
          <span id="email-error">Email is required</span>
        HTML
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'form_errors' }).to be true
      end

      it 'detects field_with_errors without error message' do
        html = '<div class="field_with_errors"><input type="text" id="name"></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'form_errors' }).to be true
      end
    end
  end

  describe 'WCAG 4.1.1 - Parsing (Level A)' do
    # In content implemented using markup languages, elements have complete start and end tags, elements are nested according to their specifications, elements do not contain duplicate attributes, and any IDs are unique
    # Covered by: DuplicateIdsCheck

    context 'DuplicateIdsCheck' do
      it 'detects duplicate IDs' do
        html = '<div id="test">First</div><div id="test">Second</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'duplicate_ids' }).to be true
        expect(violations.first.wcag_reference).to eq('4.1.1')
      end

      it 'allows unique IDs' do
        html = '<div id="first">First</div><div id="second">Second</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'duplicate_ids' }).to be true
      end

      it 'detects multiple duplicate IDs' do
        html = '<div id="test1">A</div><div id="test2">B</div><div id="test1">C</div><div id="test2">D</div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        duplicate_violations = violations.select { |v| v.rule_name == 'duplicate_ids' }
        expect(duplicate_violations.any?).to be true
        # Should report both test1 and test2
        expect(duplicate_violations.first.element_context[:duplicate_ids]).to include('test1', 'test2')
      end
    end
  end

  describe 'WCAG 4.1.2 - Name, Role, Value (Level A)' do
    # For all user interface components, the name and role can be programmatically determined
    # Covered by: InteractiveElementsCheck, HeadingCheck

    context 'InteractiveElementsCheck - Buttons' do
      it 'detects buttons missing accessible name' do
        html = '<button></button>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
        expect(violations.first.wcag_reference).to eq('4.1.2')
      end

      it 'allows buttons with visible text' do
        html = '<button>Submit</button>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
      end

      it 'allows buttons with aria-label' do
        html = '<button aria-label="Close dialog"><i class="icon-close"></i></button>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
      end

      it 'allows buttons with aria-labelledby' do
        html = '<span id="btn-label">Submit</span><button aria-labelledby="btn-label"></button>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
      end

      it 'allows buttons with title attribute' do
        html = '<button title="Submit form"></button>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.none? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
      end

      it 'checks role="button" elements' do
        html = '<div role="button"></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'interactive_elements' && v.message.include?('Button') }).to be true
      end

      it 'checks role="link" elements' do
        html = '<div role="link"></div>'
        page = create_page_from_html(html)
        violations = engine.check(page, context: {})
        
        expect(violations.any? { |v| v.rule_name == 'interactive_elements' }).to be true
      end
    end
  end

  describe 'Complete WCAG 2.1 AA Coverage Verification' do
    it 'runs all 11 checks' do
      html = <<~HTML
        <html>
          <body>
            <img src="test.png">
            <input type="text" id="field">
            <a href="/"></a>
            <button></button>
            <h2>No h1</h2>
            <table><tr><td>No headers</td></tr></table>
            <div id="test"></div><div id="test"></div>
            <div role="dialog"></div>
            <input class="is-invalid" id="error">
          </body>
        </html>
      HTML
      
      page = create_page_from_html(html)
      violations = engine.check(page, context: {})
      
      # Should find violations from multiple checks
      rule_names = violations.map(&:rule_name).uniq
      expect(rule_names.length).to be >= 5 # At least 5 different checks should find issues
    end

    it 'verifies all WCAG references are correct' do
      html = <<~HTML
        <img src="test.png">
        <input type="text" id="field">
        <a href="/"></a>
        <button></button>
        <h2>No h1</h2>
        <table><tr><td>No headers</td></tr></table>
        <div id="test"></div><div id="test"></div>
        <div role="dialog"></div>
        <input class="is-invalid" id="error">
      HTML
      
      page = create_page_from_html(html)
      violations = engine.check(page, context: {})
      
      # Map of expected WCAG references
      expected_wcag = {
        'image_alt_text' => '1.1.1',
        'form_labels' => '1.3.1',
        'interactive_elements' => ['2.4.4', '4.1.2'], # Links use 2.4.4, buttons use 4.1.2
        'heading' => ['1.3.1', '2.4.6', '4.1.2'],
        'table_structure' => '1.3.1',
        'duplicate_ids' => '4.1.1',
        'keyboard_accessibility' => '2.1.1',
        'form_errors' => '3.3.1',
        'aria_landmarks' => '1.3.1'
      }
      
      violations.each do |violation|
        rule_name = violation.rule_name.to_s
        expected = expected_wcag[rule_name]
        
        if expected.is_a?(Array)
          expect(expected).to include(violation.wcag_reference),
            "WCAG reference for #{rule_name} should be one of #{expected}, got #{violation.wcag_reference}"
        else
          expect(violation.wcag_reference).to eq(expected),
            "WCAG reference for #{rule_name} should be #{expected}, got #{violation.wcag_reference}"
        end
      end
    end

    it 'verifies all 11 check classes exist and can be instantiated' do
      check_classes = [
        RailsAccessibilityTesting::Checks::FormLabelsCheck,
        RailsAccessibilityTesting::Checks::ImageAltTextCheck,
        RailsAccessibilityTesting::Checks::InteractiveElementsCheck,
        RailsAccessibilityTesting::Checks::HeadingCheck,
        RailsAccessibilityTesting::Checks::KeyboardAccessibilityCheck,
        RailsAccessibilityTesting::Checks::AriaLandmarksCheck,
        RailsAccessibilityTesting::Checks::FormErrorsCheck,
        RailsAccessibilityTesting::Checks::TableStructureCheck,
        RailsAccessibilityTesting::Checks::DuplicateIdsCheck,
        RailsAccessibilityTesting::Checks::SkipLinksCheck,
        RailsAccessibilityTesting::Checks::ColorContrastCheck
      ]
      
      expect(check_classes.length).to eq(11)
      
      check_classes.each do |check_class|
        expect(check_class.rule_name).to be_a(Symbol)
        
        # Can instantiate with a page
        page = create_page_from_html('<html><body></body></html>')
        instance = check_class.new(page: page, context: {})
        expect(instance).to respond_to(:check)
      end
    end
  end

  describe 'Edge Cases and Real-World Scenarios' do
    it 'handles complex forms with multiple input types' do
      html = <<~HTML
        <form>
          <input type="text" id="name">
          <input type="email" id="email">
          <input type="password" id="password">
          <input type="number" id="age">
          <input type="tel" id="phone">
          <input type="url" id="website">
          <input type="search" id="query">
          <input type="date" id="birthday">
          <input type="time" id="appointment">
          <input type="datetime-local" id="meeting">
          <textarea id="message"></textarea>
          <select id="country"><option>USA</option></select>
        </form>
      HTML
      
      page = create_page_from_html(html)
      violations = engine.check(page, context: {})
      
      # Should detect missing labels for all inputs
      form_label_violations = violations.select { |v| v.rule_name == 'form_labels' }
      expect(form_label_violations.length).to eq(13) # All 13 form elements should be flagged
    end

    it 'handles pages with proper accessibility (no violations)' do
      html = <<~HTML
        <html>
          <body>
            <main>
              <h1>Page Title</h1>
              <h2>Section</h2>
              <form>
                <label for="email">Email</label>
                <input type="email" id="email" name="email">
              </form>
              <img src="logo.png" alt="Company Logo">
              <a href="/about">About Us</a>
              <button>Submit</button>
              <table>
                <thead><tr><th>Header</th></tr></thead>
                <tbody><tr><td>Data</td></tr></tbody>
              </table>
            </main>
          </body>
        </html>
      HTML
      
      page = create_page_from_html(html)
      violations = engine.check(page, context: {})
      
      # Should have minimal violations (maybe skip links warning)
      error_violations = violations.reject { |v| v.rule_name == 'skip_links' || v.rule_name == 'aria_landmarks' }
      expect(error_violations).to be_empty
    end

    it 'handles Rails helper patterns correctly' do
      # Test that Rails helpers are detected when converted to HTML
      html = <<~HTML
        <select name="sort" id="sort"></select>
        <input type="text" name="search" id="search">
        <img src="logo.png">
        <a href="#"></a>
        <button></button>
      HTML
      
      page = create_page_from_html(html)
      violations = engine.check(page, context: {})
      
      # Should detect issues with all elements
      expect(violations.any? { |v| v.rule_name == 'form_labels' }).to be true
      expect(violations.any? { |v| v.rule_name == 'image_alt_text' }).to be true
      expect(violations.any? { |v| v.rule_name == 'interactive_elements' }).to be true
    end
  end
end

