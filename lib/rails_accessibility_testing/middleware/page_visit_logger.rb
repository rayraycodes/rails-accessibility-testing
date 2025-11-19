# frozen_string_literal: true

require 'json'
require 'fileutils'

module RailsAccessibilityTesting
  module Middleware
    # Middleware to log page visits for live accessibility scanning
    # Only active in development environment
    class PageVisitLogger
      def initialize(app)
        @app = app
        @log_file = Rails.root.join('tmp', 'a11y_page_visits.log')
        FileUtils.mkdir_p(File.dirname(@log_file))
        @pending_logs = []
        @last_flush = Time.now
        @mutex = Mutex.new
        
        # Start background thread to flush logs periodically
        @flush_thread = Thread.new do
          loop do
            sleep 2 # Flush every 2 seconds
            flush_logs
          end
        end
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        
        # Only log GET requests for HTML pages in development
        if Rails.env.development? && 
           request.get? && 
           request.format.html? &&
           !request.path.start_with?('/assets', '/packs', '/rails', '/letter_opener')
          
          # Add to pending logs (thread-safe)
          @mutex.synchronize do
            @pending_logs << {
              path: request.path,
              url: request.url,
              timestamp: Time.now.to_f
            }
            
            # Flush immediately if we have 3+ pending logs
            flush_logs if @pending_logs.length >= 3
          end
        end
        
        @app.call(env)
      end

      private

      def flush_logs
        logs_to_write = []
        
        @mutex.synchronize do
          return if @pending_logs.empty?
          logs_to_write = @pending_logs.dup
          @pending_logs.clear
          @last_flush = Time.now
        end
        
        return if logs_to_write.empty?
        
        # Write all logs at once
        File.open(@log_file, 'a') do |f|
          logs_to_write.each do |log_entry|
            f.puts(log_entry.to_json)
          end
          f.flush
        end
      rescue StandardError => e
        # Silently fail - don't break the app if logging fails
        Rails.logger.debug("Failed to flush page visit logs: #{e.message}") if defined?(Rails.logger)
      end
    end
  end
end

