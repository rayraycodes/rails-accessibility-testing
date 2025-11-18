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
          profile: :test,
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
            wait_for_server(url) if url.match?(/\Ahttps?:\/\//)
            
            Capybara.visit(url)
            violations = engine.check(Capybara.current_session, context: { url: url })
            all_violations.concat(violations)
            checked_urls << { url: url, violations: violations.count }
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
        # Default to localhost:3000 (standard Rails port)
        port = ENV['PORT'] || ENV['RAILS_PORT'] || '3000'
        base_url = ENV['RAILS_URL'] || "http://localhost:#{port}"
        
        # Ensure path starts with /
        path = target.start_with?('/') ? target : "/#{target}"
        "#{base_url}#{path}"
      end
      
      def wait_for_server(url, max_retries: 10, retry_delay: 2)
        require 'net/http'
        require 'uri'
        
        uri = URI.parse(url)
        base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        
        max_retries.times do |attempt|
          begin
            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = 1
            http.read_timeout = 1
            response = http.head('/')
            return if response.code.to_i < 500 # Server is responding
          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Net::OpenTimeout, Net::ReadTimeout, SocketError
            # Server not ready yet
            if attempt < max_retries - 1
              sleep(retry_delay)
              next
            else
              # Last attempt failed, but we'll still try to visit (might be a different error)
              $stderr.puts "Warning: Server at #{base_url} not responding after #{max_retries} attempts, attempting anyway..."
              return
            end
          end
        end
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
        output = []
        output << "=" * 70
        output << "Rails A11y Accessibility Report"
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
            output << "#{index + 1}. #{violation.message}"
            output << "   Rule: #{violation.rule_name}"
            output << "   URL: #{violation.page_context[:url]}"
            output << "   View: #{violation.page_context[:view_file]}" if violation.page_context[:view_file]
            output << ""
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
            rails_a11y check /home /about
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

