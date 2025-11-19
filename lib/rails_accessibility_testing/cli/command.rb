# frozen_string_literal: true

require 'optparse'
require 'json'

module RailsAccessibilityTesting
  module CLI
    # Main CLI command for running accessibility checks
    #
    # Provides a command-line interface to run checks against
    # URLs or Rails routes.
    #
    # @example
    #   rails_a11y check /home /about
    #   rails_a11y check --urls https://example.com
    #   rails_a11y check --routes home_path about_path
    #
    class Command
      def self.run(argv)
        new.run(argv)
      end
      
      def run(argv)
        options = parse_options(argv)
        
        if options[:help]
          print_help
          return 0
        end
        
        if options[:version]
          print_version
          return 0
        end
        
        # Load configuration
        config = load_config(options[:profile])
        
        # Run checks
        results = run_checks(options, config)
        
        # Generate report
        generate_report(results, options)
        
        results[:violations].any? ? 1 : 0
      rescue StandardError => e
        $stderr.puts "Error: #{e.message}"
        $stderr.puts e.backtrace if options[:debug]
        1
      end
      
      private
      
      def parse_options(argv)
        options = {
          profile: :development,  # Use development profile by default (faster, no color contrast)
          format: :human,
          output: nil,
          debug: false
        }
        
        OptionParser.new do |opts|
          opts.banner = "Usage: rails_a11y [options] [paths...]"
          
          opts.on('-u', '--urls URL1,URL2', Array, 'Check specific URLs') do |urls|
            options[:urls] = urls
          end
          
          opts.on('-r', '--routes ROUTE1,ROUTE2', Array, 'Check Rails routes') do |routes|
            options[:routes] = routes
          end
          
          opts.on('-p', '--profile PROFILE', 'Configuration profile (development, test, ci)') do |profile|
            options[:profile] = profile.to_sym
          end
          
          opts.on('-f', '--format FORMAT', 'Output format (human, json)') do |format|
            options[:format] = format.to_sym
          end
          
          opts.on('-o', '--output FILE', 'Output file path') do |file|
            options[:output] = file
          end
          
          opts.on('--debug', 'Enable debug output') do
            options[:debug] = true
          end
          
          opts.on('-h', '--help', 'Show this help') do
            options[:help] = true
          end
          
          opts.on('-v', '--version', 'Show version') do
            options[:version] = true
          end
        end.parse!(argv)
        
        # Remaining args are paths
        options[:paths] = argv if argv.any?
        
        options
      end
      
      def load_config(profile)
        Config::YamlLoader.load(profile: profile)
      end
      
      def run_checks(options, config)
        # Reset wait attempts counter for each run
        @wait_attempts = 0
        
        require 'capybara'
        require 'capybara/dsl'
        require 'selenium-webdriver'
        
        # Try to require webdrivers for automatic chromedriver management
        begin
          require 'webdrivers'
        rescue LoadError
          # webdrivers gem not available, selenium-webdriver will try to manage drivers
        end
        
        # Setup Capybara
        Capybara.default_driver = :selenium_chrome_headless
        # Don't set Capybara.app when using Selenium - it needs a real HTTP server
        # The Rails server should be running separately (e.g., via Procfile.dev)
        
        engine = Engine::RuleEngine.new(config: config)
        all_violations = []
        checked_urls = []
        
        # Determine what to check
        targets = determine_targets(options)
        
        targets.each do |target|
          begin
            # Convert path to full URL if needed (when using Selenium with Rails)
            url = normalize_url(target)
            
            # Wait for server to be ready (with retries)
            # If wait fails, try to re-detect port and update URL
            if url.match?(/\Ahttps?:\/\//)
              # First, try to detect the port (might not be ready yet)
              uri = URI.parse(url)
              detected_port = detect_server_port
              
              # If we detected a different port, update the URL
              if detected_port != uri.port.to_s
                url = "#{uri.scheme}://#{uri.host}:#{detected_port}#{uri.path}"
              end
              
              # Now wait for server to be ready
              server_ready = wait_for_server(url, max_retries: 20, retry_delay: 1)
              
              # If still not ready, try re-detecting port one more time
              unless server_ready
                new_port = detect_server_port
                if new_port != uri.port.to_s
                  url = "#{uri.scheme}://#{uri.host}:#{new_port}#{uri.path}"
                  server_ready = wait_for_server(url, max_retries: 20, retry_delay: 1)
                end
                
                # If still not ready, skip this check and try next time
                unless server_ready
                  # Server still starting - this is normal, will retry automatically
                  # Only show message occasionally to avoid spam (every 3rd attempt)
                  @wait_attempts ||= 0
                  @wait_attempts += 1
                  if @wait_attempts % 3 == 1
                    $stderr.puts "Waiting for server to start... (will retry automatically)"
                  end
                  next
                end
              end
            end
            
            Capybara.visit(url)
            violations = engine.check(Capybara.current_session, context: { url: url })
            all_violations.concat(violations)
            checked_urls << { url: url, violations: violations.count }
          rescue Interrupt
            # Handle interrupt gracefully - exit the loop
            break
          rescue StandardError => e
            $stderr.puts "Error checking #{target}: #{e.message}"
          end
        end
        
        {
          violations: all_violations,
          checked_urls: checked_urls,
          summary: {
            total_violations: all_violations.count,
            urls_checked: checked_urls.count,
            urls_with_violations: checked_urls.count { |u| u[:violations] > 0 }
          }
        }
      end
      
      def determine_targets(options)
        targets = []
        
        if options[:urls]
          targets.concat(options[:urls])
        end
        
        if options[:routes]
          targets.concat(resolve_routes(options[:routes]))
        end
        
        if options[:paths]
          targets.concat(options[:paths])
        end
        
        targets.uniq
      end
      
      def normalize_url(target)
        # If it's already a full URL, return as-is
        return target if target.match?(/\Ahttps?:\/\//)
        
        # If it's a path and we're using Selenium, construct a full URL
        # Try to detect the actual port, or use environment variables, or default to 3000
        port = detect_server_port
        base_url = ENV['RAILS_URL'] || "http://localhost:#{port}"
        
        # Ensure path starts with /
        path = target.start_with?('/') ? target : "/#{target}"
        "#{base_url}#{path}"
      end
      
      def detect_server_port
        # Check environment variables first
        return ENV['PORT'] if ENV['PORT']
        return ENV['RAILS_PORT'] if ENV['RAILS_PORT']
        
        # Try to detect port from Rails server - check common Rails ports
        # Check in order: 3000 (most common), then others
        # Prioritize 3000 first as it's the Rails default
        common_ports = [3000, 3001, 4000, 5000]
        
        common_ports.each do |port|
          begin
            require 'net/http'
            http = Net::HTTP.new('localhost', port)
            http.open_timeout = 1
            http.read_timeout = 1
            # Try to get a response - check if it looks like a Rails server
            response = http.head('/')
            # Accept 2xx, 3xx, or 4xx responses (server is responding)
            # Reject 5xx as it might be a proxy or error
            if response.code.to_i < 500
              # Additional check: Rails servers usually have certain headers
              # But for now, any HTTP response on these common ports is likely Rails
              return port.to_s
            end
          rescue Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, SocketError, Interrupt, Errno::EHOSTUNREACH, Errno::ETIMEDOUT
            # Port not available or interrupted, try next
            next
          end
        end
        
        # Default to 3000 if nothing found
        '3000'
      end
      
      def wait_for_server(url, max_retries: 15, retry_delay: 1)
        require 'net/http'
        require 'uri'
        
        uri = URI.parse(url)
        base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        
        max_retries.times do |attempt|
          begin
            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = 2
            http.read_timeout = 2
            response = http.head('/')
            return true if response.code.to_i < 500 # Server is responding
          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::EHOSTUNREACH
            # Server not ready yet
            if attempt < max_retries - 1
              begin
                sleep(retry_delay)
              rescue Interrupt
                # Handle interrupt gracefully - return false to indicate failure
                return false
              end
              next
            else
              # Last attempt failed
              return false
            end
          rescue Interrupt
            # Handle interrupt gracefully
            return false
          end
        end
        
        false
      end
      
      def resolve_routes(routes)
        return [] unless defined?(Rails) && Rails.application
        
        routes.map do |route_name|
          begin
            Rails.application.routes.url_helpers.send(route_name)
          rescue StandardError
            nil
          end
        end.compact
      end
      
      def generate_report(results, options)
        # Don't generate report if no URLs were checked (server not ready)
        if results[:summary][:urls_checked] == 0
          return
        end
        
        output = case options[:format]
                 when :json
                   generate_json_report(results)
                 else
                   generate_human_report(results)
                 end
        
        if options[:output]
          File.write(options[:output], output)
          puts "Report written to #{options[:output]}"
        else
          puts output
        end
      end
      
      def generate_human_report(results)
        timestamp = Time.now.strftime("%H:%M:%S")
        
        output = []
        output << "=" * 70
        output << "Rails A11y Accessibility Report • #{timestamp}"
        output << "=" * 70
        output << ""
        output << "Summary:"
        output << "  Total Violations: #{results[:summary][:total_violations]}"
        output << "  URLs Checked: #{results[:summary][:urls_checked]}"
        output << "  URLs with Issues: #{results[:summary][:urls_with_violations]}"
        output << ""
        
        if results[:violations].any?
          output << "Violations:"
          output << ""
          
          results[:violations].each_with_index do |violation, index|
            # Use ErrorMessageBuilder for detailed formatted messages
            detailed_message = ErrorMessageBuilder.build(
              error_type: violation.message,
              element_context: violation.element_context || {},
              page_context: violation.page_context || {}
            )
            output << detailed_message
            output << "" if index < results[:violations].count - 1  # Add spacing between violations
          end
        else
          output << "✅ No accessibility violations found!"
        end
        
        output.join("\n")
      end
      
      def generate_json_report(results)
        {
          summary: results[:summary],
          violations: results[:violations].map(&:to_h),
          checked_urls: results[:checked_urls]
        }.to_json
      end
      
      def print_help
        puts <<~HELP
          Rails A11y - Accessibility Testing for Rails
          
          Usage: rails_a11y [options] [paths...]
          
          Options:
            -u, --urls URL1,URL2          Check specific URLs
            -r, --routes ROUTE1,ROUTE2     Check Rails routes
            -p, --profile PROFILE          Configuration profile (development, test, ci)
            -f, --format FORMAT           Output format (human, json)
            -o, --output FILE             Output file path
            --debug                       Enable debug output
            -h, --help                    Show this help
            -v, --version                 Show version
          
          Examples:
            rails_a11y /home /about
            rails_a11y /
            rails_a11y --urls https://example.com
            rails_a11y --routes home_path about_path --format json --output report.json
        HELP
      end
      
      def print_version
        puts "Rails A11y #{RailsAccessibilityTesting::VERSION}"
      end
    end
  end
end

