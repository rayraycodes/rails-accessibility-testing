require 'rails_helper'

RSpec.describe 'All Pages Accessibility', type: :system do
  # Test all view files for accessibility using static file scanning
  # Generated automatically by rails_a11y:install generator
  
  # Helper method to get all view files (non-partials)
  def self.get_all_view_files
    return [] unless defined?(Rails) && Rails.root
    
    view_dir = Rails.root.join('app', 'views')
    return [] unless File.directory?(view_dir)
    
    extensions = %w[erb haml slim]
    view_files = []
    
    extensions.each do |ext|
      # Find all HTML view files (exclude partials that start with _)
      pattern = File.join(view_dir, '**', "*.html.#{ext}")
      Dir.glob(pattern).each do |file|
        # Skip partials (files starting with _)
        next if File.basename(file).start_with?('_')
        # Skip layout files
        next if file.include?('/layouts/')
        view_files << file
      end
    end
    
    view_files.sort
  end
  
  # Format errors with file locations and line numbers
  def format_static_errors(errors, warnings)
    return "" if errors.empty? && warnings.empty?
    
    output = []
    
    # Group errors by file
    errors_by_file = errors.group_by { |e| e[:file] }
    warnings_by_file = warnings.group_by { |w| w[:file] }
    
    # Show errors first
    if errors.any?
      output << "\n" + "="*70
      output << "❌ #{errors.length} error#{'s' if errors.length != 1} found"
      output << "="*70
      output << ""
      
      errors_by_file.each_with_index do |(file_path, file_errors), file_index|
        output << "" if file_index > 0
        
        output << "📝 #{file_path} (#{file_errors.length} error#{'s' if file_errors.length != 1})"
        
        file_errors.each do |error|
          error_line = "   • #{error[:type]}"
          
          # Add line number if available
          if error[:line]
            error_line += " [Line #{error[:line]}]"
          end
          
          # Add element identifier
          if error[:element][:id].present?
            error_line += " [id: #{error[:element][:id]}]"
          elsif error[:element][:href].present?
            href_display = error[:element][:href].length > 30 ? "#{error[:element][:href][0..27]}..." : error[:element][:href]
            error_line += " [href: #{href_display}]"
          elsif error[:element][:src].present?
            src_display = error[:element][:src].length > 30 ? "#{error[:element][:src][0..27]}..." : error[:element][:src]
            error_line += " [src: #{src_display}]"
          end
          
          output << error_line
        end
      end
      
      output << ""
      output << "="*70
    end
    
    # Show warnings if any
    if warnings.any?
      output << "\n" + "="*70
      output << "⚠️  #{warnings.length} warning#{'s' if warnings.length != 1} found"
      output << "="*70
      output << ""
      
      warnings_by_file.each_with_index do |(file_path, file_warnings), file_index|
        output << "" if file_index > 0
        
        output << "📝 #{file_path} (#{file_warnings.length} warning#{'s' if file_warnings.length != 1})"
        
        file_warnings.each do |warning|
          warning_line = "   • #{warning[:type]}"
          
          # Add line number if available
          if warning[:line]
            warning_line += " [Line #{warning[:line]}]"
          end
          
          # Add element identifier
          if warning[:element][:id].present?
            warning_line += " [id: #{warning[:element][:id]}]"
          elsif warning[:element][:href].present?
            href_display = warning[:element][:href].length > 30 ? "#{warning[:element][:href][0..27]}..." : warning[:element][:href]
            warning_line += " [href: #{href_display}]"
          elsif warning[:element][:src].present?
            src_display = warning[:element][:src].length > 30 ? "#{warning[:element][:src][0..27]}..." : warning[:element][:src]
            warning_line += " [src: #{src_display}]"
          end
          
          output << warning_line
        end
      end
      
      output << ""
      output << "="*70
    end
    
    output.join("\n")
  end
  
  # Scan all view files statically
  view_files = get_all_view_files
  
  if view_files.empty?
    it "no view files found to scan" do
      skip "No view files found in app/views"
    end
  else
    view_files.each do |view_file|
      it "scans #{view_file} for accessibility issues" do
        require 'rails_accessibility_testing/static_file_scanner'
        
        scanner = RailsAccessibilityTesting::StaticFileScanner.new(view_file)
        result = scanner.scan
        
        errors = result[:errors] || []
        warnings = result[:warnings] || []
        
        if errors.any? || warnings.any?
          puts format_static_errors(errors, warnings)
          
          if errors.any?
            puts "Found #{errors.length} accessibility error#{'s' if errors.length != 1} in #{view_file}"
          end
        else
          puts "✅ #{view_file}: No errors found"
        end
      end
    end
  end
end
