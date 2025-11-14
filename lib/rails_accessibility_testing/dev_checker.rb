#!/usr/bin/env ruby
# Simple accessibility checker for dev console
# Lightweight version that just runs tests and shows errors

require 'open3'

def run_accessibility_checks
  puts "\n" + "="*60
  puts "🔍 Running Accessibility Checks..."
  puts "="*60 + "\n"
  
  stdout, stderr, status = Open3.capture3("bundle exec rspec spec/system/ --format progress --no-profile 2>&1")
  
  if status.success?
    puts "\n✅ All accessibility checks passed!\n"
    return true
  else
    puts "\n❌ Accessibility Issues Found:\n"
    puts "="*70
    
    # Parse and show full error messages with remediation steps
    lines = stdout.split("\n")
    in_failure = false
    failure_count = 0
    in_error_block = false
    
    lines.each do |line|
      # Detect start of a failure
      if line.match?(/^\s*[0-9]+\)\s+/)
        failure_count += 1
        in_failure = true
        in_error_block = false
        puts "\n#{failure_count}. #{line.strip}"
        puts "-" * 70
      # Detect the error message block (starts with RuntimeError or the ====== separator)
      elsif in_failure && (line.match?(/RuntimeError:|^={70}$/) || line.match?(/ACCESSIBILITY ERROR/))
        in_error_block = true
        puts line
      # Show all lines within the error block (remediation steps)
      elsif in_error_block
        # Stop at the screenshot line or stack trace
        if line.match?(/\[Screenshot|# \.\/lib|Shared Example Group/)
          in_error_block = false
          in_failure = false
          puts "" # Add spacing
        else
          puts line
        end
      # Show failure summary lines
      elsif in_failure && !in_error_block && line.strip.start_with?('# ./')
        puts "   #{line.strip}"
        in_failure = false
      end
    end
    
    puts "\n" + "="*70
    puts "💡 Fix the issues above, then tests will re-run automatically"
    puts "="*70 + "\n"
    return false
  end
rescue => e
  puts "❌ Error running accessibility checks: #{e.message}\n"
  return false
end

# Run if called directly
if __FILE__ == $0
  run_accessibility_checks
end

