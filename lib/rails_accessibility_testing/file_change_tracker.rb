# frozen_string_literal: true

require 'json'
require 'fileutils'

module RailsAccessibilityTesting
  # Tracks file modification times to detect changes
  # Used by static scanner to only scan files that have changed
  #
  # @api private
  class FileChangeTracker
    class << self
      # Get the path to the scan state file
      # @return [String] Path to the state file
      def state_file_path
        return @state_file_path if defined?(@state_file_path) && @state_file_path
        
        if defined?(Rails) && Rails.root
          @state_file_path = Rails.root.join('tmp', '.rails_a11y_scanned_files.json').to_s
        else
          @state_file_path = File.join(Dir.pwd, 'tmp', '.rails_a11y_scanned_files.json')
        end
      end

      # Load the last scan state
      # @return [Hash] Hash of file paths to modification times
      def load_state
        return {} unless File.exist?(state_file_path)
        
        JSON.parse(File.read(state_file_path))
      rescue StandardError
        {}
      end

      # Save the scan state
      # @param state [Hash] Hash of file paths to modification times
      def save_state(state)
        FileUtils.mkdir_p(File.dirname(state_file_path))
        
        # Atomic write to avoid partial writes
        temp_file = "#{state_file_path}.tmp"
        File.write(temp_file, JSON.pretty_generate(state))
        FileUtils.mv(temp_file, state_file_path)
      rescue StandardError => e
        # Silently fail - don't break scanning if state save fails
      end

      # Check which files have changed since last scan
      # @param files [Array<String>] List of file paths to check
      # @return [Array<String>] List of files that have changed or are new
      def changed_files(files)
        state = load_state
        changed = []
        
        files.each do |file|
          next unless File.exist?(file)
          
          current_mtime = File.mtime(file).to_f
          last_mtime = state[file]&.to_f
          
          # File is new or modified if mtime differs
          if last_mtime.nil? || current_mtime != last_mtime
            changed << file
          end
        end
        
        changed
      end

      # Update state with current file modification times
      # @param files [Array<String>] List of file paths to update
      def update_state(files)
        state = load_state
        
        files.each do |file|
          next unless File.exist?(file)
          state[file] = File.mtime(file).to_f
        end
        
        # Remove files that no longer exist
        state.delete_if { |file, _| !File.exist?(file) }
        
        save_state(state)
      end

      # Clear the scan state (useful for forcing full rescan)
      def clear_state
        File.delete(state_file_path) if File.exist?(state_file_path)
      rescue StandardError
        # Silently fail
      end
    end
  end
end

