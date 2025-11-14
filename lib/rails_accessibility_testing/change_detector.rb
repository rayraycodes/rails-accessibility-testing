# frozen_string_literal: true

module RailsAccessibilityTesting
  # Detects if relevant files have changed to determine if accessibility checks should run
  class ChangeDetector
    # Time window for considering files as "recently changed" (in seconds)
    CHANGE_WINDOW = 300 # 5 minutes

    # Directories to monitor for changes
    MONITORED_DIRECTORIES = %w[app/views app/controllers app/helpers].freeze

    # View file extensions to check
    VIEW_EXTENSIONS = %w[erb haml slim].freeze

    class << self
      # Check if relevant files have changed
      # @param current_path [String] The current Rails path being tested
      # @return [Boolean] true if files have changed, false otherwise
      def files_changed?(current_path)
        return false unless current_path

        view_file = determine_view_file_from_path(current_path)
        return true if view_file_recently_modified?(view_file)
        return true if git_has_uncommitted_changes?
        return true if any_monitored_files_recently_modified?

        false
      end

      private

      # Check if a specific view file was recently modified
      def view_file_recently_modified?(view_file)
        return false unless view_file && File.exist?(view_file)

        File.mtime(view_file) > Time.now - CHANGE_WINDOW
      end

      # Check if git has uncommitted changes in monitored directories
      def git_has_uncommitted_changes?
        git_status = `git status --porcelain #{MONITORED_DIRECTORIES.join(' ')} 2>/dev/null`
        git_status.strip.length.positive?
      rescue StandardError
        false # Git not available or not a git repo
      end

      # Check if any monitored files were recently modified
      def any_monitored_files_recently_modified?
        monitored_files.any? do |file|
          File.exist?(file) && File.mtime(file) > Time.now - CHANGE_WINDOW
        end
      end

      # Get all monitored files
      def monitored_files
        view_files + controller_files + helper_files
      end

      # Get all view files
      def view_files
        VIEW_EXTENSIONS.flat_map do |ext|
          Dir.glob("app/views/**/*.#{ext}")
        end
      end

      # Get all controller files
      def controller_files
        Dir.glob('app/controllers/**/*.rb')
      end

      # Get all helper files
      def helper_files
        Dir.glob('app/helpers/**/*.rb')
      end

      # Determine view file from Rails path
      def determine_view_file_from_path(path)
        return nil unless path

        clean_path = path.split('?').first.split('#').first
        return nil unless clean_path.start_with?('/')

        parts = clean_path.sub(/\A\//, '').split('/')
        return nil if parts.empty?

        find_view_file(parts)
      end

      # Find view file based on path parts
      def find_view_file(parts)
        if parts.length >= 2
          controller = parts[0..-2].join('/')
          action = parts.last
          find_view_for_action(controller, action)
        elsif parts.length == 1
          find_view_for_action(parts[0], 'index')
        end
      end

      # Find view file for a specific controller and action
      def find_view_for_action(controller, action)
        view_paths = VIEW_EXTENSIONS.flat_map do |ext|
          [
            "app/views/#{controller}/#{action}.html.#{ext}",
            "app/views/#{controller}/_#{action}.html.#{ext}"
          ]
        end

        view_paths.find { |vp| File.exist?(vp) }
      end
    end
  end
end

