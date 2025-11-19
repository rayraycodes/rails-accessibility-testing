#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to create GitHub issues from POTENTIAL_ISSUES.md
# Usage: GITHUB_TOKEN=your_token ruby scripts/create_issues.rb

require 'net/http'
require 'json'
require 'uri'

GITHUB_REPO = 'rayraycodes/rails-accessibility-testing'
GITHUB_API = 'https://api.github.com'

# Get GitHub token from environment
GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ENV['GITHUB_TOKEN']

unless GITHUB_TOKEN
  puts "❌ Error: GITHUB_TOKEN environment variable not set"
  puts "   Set it with: export GITHUB_TOKEN=your_token"
  puts "   Or create a token at: https://github.com/settings/tokens"
  exit 1
end

# Parse POTENTIAL_ISSUES.md to extract issues
def parse_issues_from_file(file_path)
  issues = []
  current_section = nil
  current_issue = nil
  
  File.readlines(file_path).each do |line|
    # Detect section headers
    if line.match?(/^### (.+)$/)
      current_section = $1.strip
      next
    end
    
    # Detect issue number and title
    if line.match?(/^\d+\. \*\*(.+?)\*\*/)
      # Save previous issue if exists
      issues << current_issue if current_issue
      
      current_issue = {
        title: $1.strip,
        body: [],
        section: current_section,
        labels: determine_labels(current_section)
      }
      next
    end
    
    # Collect body lines
    if current_issue && line.strip.length > 0
      # Skip markdown formatting for issue body
      clean_line = line.gsub(/^\s*-\s*/, '').strip
      current_issue[:body] << clean_line if clean_line.length > 0
    end
  end
  
  # Add last issue
  issues << current_issue if current_issue
  
  issues
end

def determine_labels(section)
  labels = ['enhancement']
  
  case section
  when /Testing|Coverage/
    labels << 'testing'
  when /Feature/
    labels << 'feature'
  when /Limitation/
    labels << 'documentation'
  when /Technical/
    labels << 'technical-debt'
  when /Accessibility/
    labels << 'accessibility'
  end
  
  labels
end

def create_issue(title, body, labels)
  uri = URI("#{GITHUB_API}/repos/#{GITHUB_REPO}/issues")
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Post.new(uri.path)
  # GitHub API accepts both "token" and "Bearer" - try Bearer first (newer format)
  request['Authorization'] = "Bearer #{GITHUB_TOKEN}"
  request['Accept'] = 'application/vnd.github.v3+json'
  request['Content-Type'] = 'application/json'
  request['User-Agent'] = 'Rails-A11y-Issue-Creator'
  
  issue_data = {
    title: title,
    body: body,
    labels: labels
  }
  
  request.body = issue_data.to_json
  
  response = http.request(request)
  
  case response.code.to_i
  when 201
    issue = JSON.parse(response.body)
    {
      success: true,
      number: issue['number'],
      url: issue['html_url']
    }
  when 401
    {
      success: false,
      error: "Authentication failed - check your token is valid and has 'repo' scope",
      code: response.code
    }
  when 403
    {
      success: false,
      error: "Permission denied - token may not have 'repo' scope or rate limit exceeded",
      code: response.code
    }
  when 404
    {
      success: false,
      error: "Repository not found - check GITHUB_REPO is correct",
      code: response.code
    }
  else
    error_body = begin
      JSON.parse(response.body)
    rescue
      response.body
    end
    
    error_msg = if error_body.is_a?(Hash) && error_body['message']
      error_body['message']
    else
      response.body[0..200] # First 200 chars
    end
    
    {
      success: false,
      error: "#{error_msg} (HTTP #{response.code})",
      code: response.code
    }
  end
rescue => e
  {
    success: false,
    error: "#{e.message} (#{e.class})"
  }
end

# Main execution
def main
  issues_file = File.join(__dir__, '..', 'POTENTIAL_ISSUES.md')
  
  unless File.exist?(issues_file)
    puts "❌ Error: POTENTIAL_ISSUES.md not found at #{issues_file}"
    exit 1
  end
  
  puts "📖 Parsing POTENTIAL_ISSUES.md..."
  issues = parse_issues_from_file(issues_file)
  
  puts "📋 Found #{issues.length} potential issues"
  puts ""
  puts "⚠️  This will create #{issues.length} GitHub issues."
  print "Continue? (y/N): "
  
  confirmation = $stdin.gets.chomp.downcase
  unless confirmation == 'y' || confirmation == 'yes'
    puts "Cancelled."
    exit 0
  end
  
  puts ""
  puts "🚀 Creating issues..."
  puts ""
  
  created = []
  failed = []
  
  issues.each_with_index do |issue, index|
    title = "[#{issue[:section]}] #{issue[:title]}"
    body = issue[:body].join("\n\n")
    body += "\n\n---\n\n*This issue was automatically created from POTENTIAL_ISSUES.md*"
    
    print "  [#{index + 1}/#{issues.length}] Creating: #{title}... "
    $stdout.flush
    
    result = create_issue(title, body, issue[:labels])
    
    if result[:success]
      puts "✅ ##{result[:number]}"
      created << { number: result[:number], url: result[:url], title: title }
    else
      puts "❌ Failed: #{result[:error]}"
      failed << { title: title, error: result[:error] }
    end
    
    # Rate limiting: GitHub allows 5000 requests/hour, but be nice
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
      puts "  ##{issue[:number]}: #{issue[:title]}"
      puts "     #{issue[:url]}"
    end
  end
  
  if failed.any?
    puts ""
    puts "Failed Issues:"
    failed.each do |issue|
      puts "  - #{issue[:title]}"
      puts "    Error: #{issue[:error]}"
    end
  end
  
  puts ""
  puts "View all issues: https://github.com/#{GITHUB_REPO}/issues"
end

main if __FILE__ == $0

