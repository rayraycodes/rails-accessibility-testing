# frozen_string_literal: true

# Shared examples for testing accessibility checks
# Provides common test patterns that all checks should follow

RSpec.shared_examples 'an accessibility check' do |check_class|
  describe 'check interface' do
    it 'defines a rule_name class method' do
      expect(check_class).to respond_to(:rule_name)
      expect(check_class.rule_name).to be_a(Symbol)
    end

    it 'can be instantiated with page and context' do
      page = double('page')
      context = { url: '/test' }
      check = check_class.new(page: page, context: context)
      
      expect(check).to be_a(RailsAccessibilityTesting::Checks::BaseCheck)
      expect(check.page).to eq(page)
      expect(check.context).to eq(context)
    end

    it 'implements the check method' do
      page = double('page')
      check = check_class.new(page: page, context: {})
      
      expect(check).to respond_to(:check)
    end

    it 'returns an array of violations' do
      page = double('page')
      check = check_class.new(page: page, context: {})
      
      # Stub page methods that might be called
      allow(page).to receive(:all).and_return([])
      allow(page).to receive(:has_css?).and_return(false)
      
      result = check.check
      expect(result).to be_an(Array)
      result.each do |violation|
        expect(violation).to be_a(RailsAccessibilityTesting::Engine::Violation)
      end
    end
  end

  describe 'error handling' do
    it 'handles page errors gracefully' do
      page = double('page')
      allow(page).to receive(:all).and_raise(StandardError.new('Page error'))
      
      check = check_class.new(page: page, context: {})
      
      expect { check.check }.not_to raise_error
      expect(check.check).to eq([])
    end
  end
end

RSpec.shared_examples 'detects violations' do |check_class, invalid_html, expected_violations|
  it 'detects violations in invalid HTML' do
    app = CapybaraTestHelpers::TestApp.new(invalid_html)
    page = Capybara::Session.new(:rack_test, app)
    page.visit('/')
    
    check = check_class.new(page: page, context: { url: '/test' })
    
    violations = check.check
    
    expect(violations).not_to be_empty
    expect(violations.length).to be >= expected_violations if expected_violations
    
    violations.each do |violation|
      expect(violation).to be_a(RailsAccessibilityTesting::Engine::Violation)
      expect(violation.rule_name).to eq(check_class.rule_name.to_s)
      expect(violation.message).to be_a(String)
      expect(violation.message).not_to be_empty
    end
  end
end

RSpec.shared_examples 'does not flag valid HTML' do |check_class, valid_html|
  it 'does not flag valid HTML patterns' do
    app = CapybaraTestHelpers::TestApp.new(valid_html)
    page = Capybara::Session.new(:rack_test, app)
    page.visit('/')
    
    check = check_class.new(page: page, context: { url: '/test' })
    
    violations = check.check
    
    expect(violations).to be_empty
  end
end

