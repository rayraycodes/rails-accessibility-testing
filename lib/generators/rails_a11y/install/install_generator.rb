# frozen_string_literal: true

require 'rails/generators/base'
require 'fileutils'

module RailsA11y
  # Generator to install Rails Accessibility Testing
  #
  # Creates initializer and configuration file.
  #
  # @example
  #   rails generate rails_a11y:install
  #
  class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      desc "Install Rails A11y: creates initializer and configuration file"
      
      def create_initializer
        template 'initializer.rb.erb', 'config/initializers/rails_a11y.rb'
      end
      
      def create_config_file
        template 'accessibility.yml.erb', 'config/accessibility.yml'
      end
      
      def add_to_rails_helper
        rails_helper_path = 'spec/rails_helper.rb'
        
        if File.exist?(rails_helper_path)
          rails_helper_content = File.read(rails_helper_path)
          
          # Add rails_accessibility_testing require
          unless rails_helper_content.include?("require 'rails_accessibility_testing'")
            inject_into_file rails_helper_path,
              after: "require 'rspec/rails'\n" do
              "require 'rails_accessibility_testing'\n"
            end
          end
        else
          say "⚠️  spec/rails_helper.rb not found. Please add: require 'rails_accessibility_testing'", :yellow
        end
      end
      
      def create_all_pages_spec
        spec_path = 'spec/system/all_pages_accessibility_spec.rb'
        
        if File.exist?(spec_path)
          say "⚠️  #{spec_path} already exists. Skipping creation.", :yellow
        else
          template 'all_pages_accessibility_spec.rb.erb', spec_path
          say "✅ Created #{spec_path}", :green
        end
      end
      
              def update_procfile_dev
                procfile_path = 'Procfile.dev'
                
                if File.exist?(procfile_path)
                  procfile_content = File.read(procfile_path)
                  modified = false
                  
                  # Update web line to use rails_server_safe if it's using standard rails server
                  if procfile_content.match?(/^web:\s*bin\/rails server/)
                    procfile_content.gsub!(/^web:\s*bin\/rails server/, 'web: bundle exec rails_server_safe')
                    modified = true
                    say "✅ Updated web process to use rails_server_safe in #{procfile_path}", :green
                    say "   💡 This prevents Foreman from terminating processes when server is already running", :cyan
                  end
                  
                  # Check if a11y line already exists
                  unless procfile_content.include?('a11y:')
                    # Add static scanner to Procfile.dev
                    a11y_line = "a11y: bundle exec a11y_static_scanner\n"
                    procfile_content += a11y_line
                    modified = true
                    say "✅ Added static accessibility scanner to #{procfile_path}", :green
                    say "   💡 Run 'bin/dev' to scan all view files and show errors", :cyan
                  else
                    # Update existing a11y line if it's using live scanner
                    if procfile_content.include?('a11y_live_scanner')
                      procfile_content.gsub!(/a11y:.*a11y_live_scanner/, 'a11y: bundle exec a11y_static_scanner')
                      modified = true
                      say "✅ Updated a11y scanner to static file scanner in #{procfile_path}", :green
                    else
                      say "⚠️  Procfile.dev already contains an a11y entry. Skipping.", :yellow
                    end
                  end
                  
                  # Save if we made changes
                  File.write(procfile_path, procfile_content) if modified
                else
                  # Create Procfile.dev if it doesn't exist
                  # Use rails_server_safe to prevent Foreman termination issues
                  procfile_content = <<~PROCFILE
                    web: bundle exec rails_server_safe
                    a11y: bundle exec a11y_static_scanner
                  PROCFILE
                  
                  File.write(procfile_path, procfile_content)
                  say "✅ Created #{procfile_path} with static accessibility scanner", :green
                  say "   💡 Using rails_server_safe to prevent Foreman process termination", :cyan
                  say "   💡 Run 'bin/dev' to scan all view files and show errors", :cyan
                end
              end
      
      def update_gitignore
        # No longer needed - static scanner doesn't create tmp files
      end
      
      def show_instructions
        say "\n✅ Rails Accessibility Testing installed successfully!", :green
        say "\n📋 Next Steps:", :yellow
        say ""
        say "  1. Run the accessibility tests:", :cyan
        say "     bundle exec rspec spec/system/all_pages_accessibility_spec.rb"
        say ""
        say "  2. For static file scanning during development:", :cyan
        say "     bin/dev  # Starts web server + static accessibility scanner"
        say "     # Scans all view files and shows errors automatically!"
        say ""
        say "  3. Create custom specs for specific pages:", :cyan
        say "     # spec/system/my_page_accessibility_spec.rb"
        say "     RSpec.describe 'My Page', type: :system do"
        say "       it 'is accessible' do"
        say "         visit my_page_path"
        say "         check_comprehensive_accessibility"
        say "       end"
        say "     end"
        say ""
        say "  4. Configure which checks run in config/accessibility.yml", :cyan
        say ""
        say "  5. Accessibility checks run automatically after each 'visit' in system specs!", :cyan
        say ""
        say "📚 Documentation:", :yellow
        say "   • README: https://github.com/rayraycodes/rails-accessibility-testing"
        say ""
      end
  end
end

