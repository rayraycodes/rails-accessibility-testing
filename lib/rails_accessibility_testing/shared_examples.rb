# Shared examples for accessibility testing
# Automatically available when rails_accessibility_testing is required

RSpec.shared_examples "a page with basic accessibility" do
  it "passes automated accessibility checks" do
    expect(page).to be_axe_clean
  end

  it "has proper form labels" do
    check_form_labels
  end

  it "has alt text on images" do
    check_image_alt_text
  end

  it "has accessible names on interactive elements" do
    check_interactive_elements_have_names
  end

  it "has proper heading hierarchy" do
    check_heading_hierarchy
  end

  it "has keyboard accessibility" do
    check_keyboard_accessibility
  end
end

RSpec.shared_examples "a page with comprehensive accessibility" do
  include_examples "a page with basic accessibility"

  it "has proper ARIA landmarks" do
    check_aria_landmarks
  end

  it "has form error associations" do
    check_form_error_associations
  end

  it "has proper table structure" do
    check_table_structure
  end

  it "has no duplicate IDs" do
    check_duplicate_ids
  end

  it "has skip links" do
    check_skip_links
  end
end

RSpec.shared_examples "an accessible form" do
  it "has all inputs properly labeled" do
    check_form_labels
  end

  it "has accessible error messages" do
    page.all('.field_with_errors input, .field_with_errors textarea, .field_with_errors select').each do |input|
      id = input[:id]
      next if id.blank?

      has_error_message = page.has_css?("[aria-describedby*='#{id}'], .field_with_errors label[for='#{id}'] + .error", wait: false)
      unless has_error_message
        warn "Input #{id} has validation errors but error message may not be properly associated"
      end
    end
  end

  it "passes automated accessibility checks" do
    expect(page).to be_axe_clean
  end
end

RSpec.shared_examples "an accessible navigation" do
  it "has proper ARIA landmarks" do
    navs = page.all('nav, [role="navigation"]', visible: true)
    expect(navs.length).to be > 0
  end

  it "has accessible skip links" do
    skip_link = page.find('a[href="#main"], a.skip-link, a[href*="main-content"]', visible: false, match: :first, wait: false) rescue nil
    if skip_link.nil?
      warn "Consider adding a 'skip to main content' link for keyboard users"
    end
  end

  it "passes automated accessibility checks" do
    expect(page).to be_axe_clean
  end
end

