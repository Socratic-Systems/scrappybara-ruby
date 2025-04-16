# frozen_string_literal: true

module Scrappybara
  # Helper module for instance operations
  module Instance
    # Get information about an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response containing instance information
    def self.get(client, instance_id, request_options: nil)
      client.instance.get(instance_id, request_options: request_options)
    end

    # Stop an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response indicating success
    def self.stop(client, instance_id, request_options: nil)
      client.instance.stop(instance_id, request_options: request_options)
    end

    # Pause an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response indicating success
    def self.pause(client, instance_id, request_options: nil)
      client.instance.pause(instance_id, request_options: request_options)
    end

    # Resume an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param timeout_hours [Integer] Number of hours to run before timeout (optional)
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response indicating success
    def self.resume(client, instance_id, timeout_hours: nil, request_options: nil)
      client.instance.resume(instance_id, timeout_hours: timeout_hours, request_options: request_options)
    end

    # Take a screenshot of an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response containing screenshot data
    def self.screenshot(client, instance_id, request_options: nil)
      client.instance.screenshot(instance_id, request_options: request_options)
    end

    # Get the stream URL for an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response containing the stream URL
    def self.get_stream_url(client, instance_id, request_options: nil)
      client.instance.get_stream_url(instance_id, request_options: request_options)
    end

    # Execute a bash command on an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param command [String] The command to execute
    # @param wait [Boolean] Whether to wait for command completion (optional)
    # @param restart [Boolean] Whether to restart the shell (optional)
    # @param get_background_processes [Boolean] Whether to get background processes (optional)
    # @param kill_pid [Integer] Process ID to kill (optional)
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response containing command output
    def self.bash(client, instance_id, command:, wait: nil, restart: nil, 
                  get_background_processes: nil, kill_pid: nil, request_options: nil)
      client.instance.bash(
        instance_id, 
        command: command,
        wait: wait,
        restart: restart,
        get_background_processes: get_background_processes,
        kill_pid: kill_pid,
        request_options: request_options
      )
    end

    # Perform file operations on an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param command [String] The file command to execute
    # @param path [String] File path (optional)
    # @param content [String] File content (optional)
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response from the file operation
    def self.file(client, instance_id, command:, path: nil, content: nil, request_options: nil)
      client.instance.file(
        instance_id,
        command: command,
        path: path,
        content: content,
        request_options: request_options
      )
    end

    # Upload a file to an instance
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param instance_id [String] The instance ID
    # @param path [String] Destination path on the instance
    # @param file [File] The file to upload
    # @param request_options [Hash] Request options (optional)
    #
    # @return [Hash] Response indicating success
    def self.upload(client, instance_id, path:, file:, request_options: nil)
      client.instance.upload(
        instance_id,
        path: path,
        file: file,
        request_options: request_options
      )
    end
  end
end