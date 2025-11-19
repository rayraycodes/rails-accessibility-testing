#!/usr/bin/env ruby
# frozen_string_literal: true

# Debug version - shows more details
require 'net/http'
require 'json'
require 'uri'

GITHUB_REPO = 'rayraycodes/rails-accessibility-testing'
GITHUB_API = 'https://api.github.com'
GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ENV['GH_TOKEN']

puts "=" * 70
puts "DEBUG MODE - Issue Creation Script"
puts "=" * 70
puts ""

unless GITHUB_TOKEN
  puts "❌ Error: GITHUB_TOKEN environment variable not set"
  puts "   Set it with: export GITHUB_TOKEN=your_token"
  exit 1
end

puts "✅ Token found (starts with: #{GITHUB_TOKEN[0..10]}...)"
puts ""

# Parse issues
issues_file = File.join(__dir__, '..', 'POTENTIAL_ISSUES.md')

unless File.exist?(issues_file)
  puts "❌ Error: POTENTIAL_ISSUES.md not found at #{issues_file}"
  exit 1
end

puts "✅ Found POTENTIAL_ISSUES.md"
puts ""

# Simple parsing
issues = []
current_section = nil
current_issue = nil

File.readlines(issues_file).each_with_index do |line, line_num|
  # Detect section headers
  if line.match?(/^### (.+)$/)
    current_section = $1.strip
    puts "📂 Section: #{current_section} (line #{line_num + 1})"
    next
  end
  
  # Detect issue number and title
  if line.match?(/^\d+\. \*\*(.+?)\*\*/)
    # Save previous issue if exists
    if current_issue
      issues << current_issue
      puts "  ✅ Saved issue: #{current_issue[:title]}"
    end
    
    current_issue = {
      title: $1.strip,
      body: [],
      section: current_section || "Unknown",
      labels: ['enhancement']
    }
    puts "  📝 Found issue ##{issues.length + 1}: #{current_issue[:title]}"
    next
  end
  
  # Collect body lines
  if current_issue && line.strip.length > 0 && !line.match?(/^#/)
    clean_line = line.gsub(/^\s*-\s*/, '').strip
    current_issue[:body] << clean_line if clean_line.length > 0
  end
end

# Add last issue
if current_issue
  issues << current_issue
  puts "  ✅ Saved final issue: #{current_issue[:title]}"
end

puts ""
puts "=" * 70
puts "📊 Parsing Summary"
puts "=" * 70
puts "Total issues found: #{issues.length}"
puts ""

if issues.length == 0
  puts "❌ No issues found! Check POTENTIAL_ISSUES.md format"
  exit 1
end

puts "First 3 issues:"
issues.first(3).each_with_index do |issue, i|
  puts "  #{i+1}. [#{issue[:section]}] #{issue[:title]}"
  puts "     Body lines: #{issue[:body].length}"
end

puts ""
puts "=" * 70
puts "Ready to create #{issues.length} issues"
puts "=" * 70
print "Continue? (y/N): "

confirmation = $stdin.gets.chomp.downcase
unless confirmation == 'y' || confirmation == 'yes'
  puts "Cancelled."
  exit 0
end

puts ""
puts "🚀 Creating issues..."
puts ""

# Create issues function
def create_issue(title, body, labels, token)
  uri = URI("#{GITHUB_API}/repos/#{GITHUB_REPO}/issues")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.path)
  request['Authorization'] = "Bearer #{token}"
  request['Accept'] = 'application/vnd.github.v3+json'
  request['Content-Type'] = 'application/json'
  request['User-Agent'] = 'Rails-A11y-Issue-Creator'
  
  issue_data = {
    title: title,
    body: body.join("\n\n"),
    labels: labels
  }
  
  request.body = issue_data.to_json
  
  response = http.request(request)
  
  case response.code.to_i
  when 201
    issue = JSON.parse(response.body)
    { success: true, number: issue['number'], url: issue['html_url'] }
  else
    error_body = begin
      JSON.parse(response.body)
    rescue
      response.body
    end
    error_msg = error_body.is_a?(Hash) && error_body['message'] ? error_body['message'] : response.body[0..200]
    { success: false, error: "#{error_msg} (HTTP #{response.code})", code: response.code }
  end
rescue => e
  { success: false, error: "#{e.message} (#{e.class})" }
end

created = []
failed = []

issues.each_with_index do |issue, index|
  title = "[#{issue[:section]}] #{issue[:title]}"
  body = issue[:body]
  body << "\n\n---\n\n*This issue was automatically created from POTENTIAL_ISSUES.md*"
  
  print "  [#{index + 1}/#{issues.length}] Creating: #{title[0..50]}... "
  $stdout.flush
  
  result = create_issue(title, body, issue[:labels], GITHUB_TOKEN)
  
  if result[:success]
    puts "✅ ##{result[:number]}"
    created << { number: result[:number], url: result[:url], title: title }
  else
    # Try without labels if label error
    if result[:code].to_i == 422 && result[:error].to_s.downcase.include?('label')
      print "⚠️  Retrying without labels... "
      $stdout.flush
      result = create_issue(title, body, [], GITHUB_TOKEN)
      if result[:success]
        puts "✅ ##{result[:number]}"
        created << { number: result[:number], url: result[:url], title: title }
      else
        puts "❌ Failed: #{result[:error]}"
        failed << { title: title, error: result[:error] }
      end
    else
      puts "❌ Failed: #{result[:error]}"
      failed << { title: title, error: result[:error] }
    end
  end
  
  sleep 0.5
end

puts ""
puts "=" * 70
puts "📊 Summary"
puts "=" * 70
puts "✅ Created: #{created.length} issues"
puts "❌ Failed: #{failed.length} issues"
puts ""

if created.any?
  puts "Created Issues:"
  created.each do |issue|
    puts "  ##{issue[:number]}: #{issue[:title][0..60]}"
    puts "     #{issue[:url]}"
  end
end

if failed.any?
  puts ""
  puts "Failed Issues:"
  failed.each do |issue|
    puts "  - #{issue[:title][0..60]}"
    puts "    Error: #{issue[:error]}"
  end
end

puts ""
puts "View all issues: https://github.com/#{GITHUB_REPO}/issues"

