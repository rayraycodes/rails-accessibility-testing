#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick test script to verify GitHub token works
require 'net/http'
require 'json'
require 'uri'

GITHUB_TOKEN = ENV['GITHUB_TOKEN']

unless GITHUB_TOKEN
  puts "❌ GITHUB_TOKEN not set"
  exit 1
end

puts "🔍 Testing GitHub token..."
puts "Token starts with: #{GITHUB_TOKEN[0..10]}..."
puts ""

# Test 1: Check if token is valid
puts "1. Testing token authentication..."
uri = URI("https://api.github.com/user")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = "Bearer #{GITHUB_TOKEN}"
request['Accept'] = 'application/vnd.github.v3+json'

response = http.request(request)

if response.code.to_i == 200
  user = JSON.parse(response.body)
  puts "   ✅ Token is valid!"
  puts "   Logged in as: #{user['login']}"
else
  puts "   ❌ Token authentication failed"
  puts "   Error: #{response.body}"
  exit 1
end

puts ""

# Test 2: Check repository access
puts "2. Testing repository access..."
repo_uri = URI("https://api.github.com/repos/rayraycodes/rails-accessibility-testing")
repo_request = Net::HTTP::Get.new(repo_uri.path)
repo_request['Authorization'] = "Bearer #{GITHUB_TOKEN}"
repo_request['Accept'] = 'application/vnd.github.v3+json'

repo_response = http.request(repo_request)

if repo_response.code.to_i == 200
  repo = JSON.parse(repo_response.body)
  puts "   ✅ Repository access granted!"
  puts "   Repository: #{repo['full_name']}"
else
  puts "   ❌ Cannot access repository"
  puts "   Error: #{repo_response.body}"
  exit 1
end

puts ""

# Test 3: Try creating a test issue
puts "3. Testing issue creation..."
issue_uri = URI("https://api.github.com/repos/rayraycodes/rails-accessibility-testing/issues")
issue_request = Net::HTTP::Post.new(issue_uri.path)
issue_request['Authorization'] = "Bearer #{GITHUB_TOKEN}"
issue_request['Accept'] = 'application/vnd.github.v3+json'
issue_request['Content-Type'] = 'application/json'

test_issue = {
  title: "[TEST] Token Verification Test - Please Delete",
  body: "This is a test issue to verify the GitHub token works. Please delete this issue after verification."
}

issue_request.body = test_issue.to_json
issue_response = http.request(issue_request)

if issue_response.code.to_i == 201
  issue = JSON.parse(issue_response.body)
  puts "   ✅ Issue creation works!"
  puts "   Created test issue: ##{issue['number']}"
  puts "   URL: #{issue['html_url']}"
  puts ""
  puts "   ⚠️  Please delete this test issue:"
  puts "   #{issue['html_url']}"
else
  puts "   ❌ Issue creation failed"
  puts "   Status: #{issue_response.code}"
  puts "   Error: #{issue_response.body}"
end

puts ""
puts "✅ Token test complete!"

