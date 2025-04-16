# frozen_string_literal: true

module Scrappybara
  module Instance
    class Client
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end

      def get(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response)
      end

      def stop(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/stop",
          method: :post,
          request_options: request_options
        )
        
        handle_response(response)
      end

      def pause(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/pause",
          method: :post,
          request_options: request_options
        )
        
        handle_response(response)
      end

      def resume(instance_id, timeout_hours: nil, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/resume",
          method: :post,
          json: {
            timeout_hours: timeout_hours
          },
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def screenshot(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/screenshot",
          method: :post,
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def get_stream_url(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/stream_url",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def bash(instance_id, command:, wait: OMIT, restart: OMIT, 
               get_background_processes: OMIT, kill_pid: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/bash",
          method: :post,
          json: {
            command: command,
            wait: wait,
            restart: restart,
            get_background_processes: get_background_processes,
            kill_pid: kill_pid
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end
      
      def upload(instance_id, path:, file:, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/upload",
          method: :post,
          files: {
            file: file
          },
          params: {
            path: path
          },
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def file(instance_id, command:, path: OMIT, content: OMIT, mode: OMIT, 
               encoding: OMIT, view_range: OMIT, recursive: OMIT, src: OMIT, 
               dst: OMIT, old_str: OMIT, new_str: OMIT, line: OMIT, text: OMIT,
               lines: OMIT, all_occurrences: OMIT, pattern: OMIT, 
               case_sensitive: OMIT, line_numbers: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/file",
          method: :post,
          json: {
            command: command,
            path: path,
            content: content,
            mode: mode,
            encoding: encoding,
            view_range: view_range,
            recursive: recursive,
            src: src,
            dst: dst,
            old_str: old_str,
            new_str: new_str,
            line: line,
            text: text,
            lines: lines,
            all_occurrences: all_occurrences,
            pattern: pattern,
            case_sensitive: case_sensitive,
            line_numbers: line_numbers
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end
      
      def computer(instance_id, action:, button: OMIT, click_type: OMIT, 
                  coordinates: OMIT, delta_x: OMIT, delta_y: OMIT, num_clicks: OMIT,
                  hold_keys: OMIT, path: OMIT, keys: OMIT, text: OMIT, 
                  duration: OMIT, screenshot: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/computer",
          method: :post,
          json: {
            action: action,
            button: button,
            click_type: click_type,
            coordinates: coordinates,
            delta_x: delta_x,
            delta_y: delta_y,
            num_clicks: num_clicks,
            hold_keys: hold_keys,
            path: path,
            keys: keys,
            text: text,
            duration: duration,
            screenshot: screenshot
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end

      private
      
      def handle_response(response)
        if response.status >= 200 && response.status < 300
          parse_response(response)
        else
          handle_error_response(response)
        end
      end
      
      def parse_response(response)
        if response.headers["content-type"]&.include?("application/json")
          JSON.parse(response.body, symbolize_names: true)
        else
          response.body
        end
      end
      
      def handle_error_response(response)
        error_body = response.body
        
        begin
          error_body = JSON.parse(error_body) if error_body.is_a?(String)
        rescue JSON::ParserError
          # Keep the original error body if it can't be parsed as JSON
        end
        
        case response.status
        when 422
          raise Scrappybara::Errors::UnprocessableEntityError.new(error_body)
        else
          raise Scrappybara::Core::ApiError.new(status_code: response.status, body: error_body)
        end
      end
    end

    class AsyncClient
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end

      def get(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}",
            method: :get,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def stop(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/stop",
            method: :post,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def pause(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/pause",
            method: :post,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def resume(instance_id, timeout_hours: nil, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/resume",
            method: :post,
            json: {
              timeout_hours: timeout_hours
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def screenshot(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/screenshot",
            method: :post,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def get_stream_url(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/stream_url",
            method: :get,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def bash(instance_id, command:, wait: OMIT, restart: OMIT, 
               get_background_processes: OMIT, kill_pid: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/bash",
            method: :post,
            json: {
              command: command,
              wait: wait,
              restart: restart,
              get_background_processes: get_background_processes,
              kill_pid: kill_pid
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end
      
      def upload(instance_id, path:, file:, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/upload",
            method: :post,
            files: {
              file: file
            },
            params: {
              path: path
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def file(instance_id, command:, path: OMIT, content: OMIT, mode: OMIT, 
               encoding: OMIT, view_range: OMIT, recursive: OMIT, src: OMIT, 
               dst: OMIT, old_str: OMIT, new_str: OMIT, line: OMIT, text: OMIT,
               lines: OMIT, all_occurrences: OMIT, pattern: OMIT, 
               case_sensitive: OMIT, line_numbers: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/file",
            method: :post,
            json: {
              command: command,
              path: path,
              content: content,
              mode: mode,
              encoding: encoding,
              view_range: view_range,
              recursive: recursive,
              src: src,
              dst: dst,
              old_str: old_str,
              new_str: new_str,
              line: line,
              text: text,
              lines: lines,
              all_occurrences: all_occurrences,
              pattern: pattern,
              case_sensitive: case_sensitive,
              line_numbers: line_numbers
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end
      
      def computer(instance_id, action:, button: OMIT, click_type: OMIT, 
                  coordinates: OMIT, delta_x: OMIT, delta_y: OMIT, num_clicks: OMIT,
                  hold_keys: OMIT, path: OMIT, keys: OMIT, text: OMIT, 
                  duration: OMIT, screenshot: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/computer",
            method: :post,
            json: {
              action: action,
              button: button,
              click_type: click_type,
              coordinates: coordinates,
              delta_x: delta_x,
              delta_y: delta_y,
              num_clicks: num_clicks,
              hold_keys: hold_keys,
              path: path,
              keys: keys,
              text: text,
              duration: duration,
              screenshot: screenshot
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end

      private
      
      def handle_response(response)
        if response.status >= 200 && response.status < 300
          parse_response(response)
        else
          handle_error_response(response)
        end
      end
      
      def parse_response(response)
        if response.headers["content-type"]&.include?("application/json")
          JSON.parse(response.body, symbolize_names: true)
        else
          response.body
        end
      end
      
      def handle_error_response(response)
        error_body = response.body
        
        begin
          error_body = JSON.parse(error_body) if error_body.is_a?(String)
        rescue JSON::ParserError
          # Keep the original error body if it can't be parsed as JSON
        end
        
        case response.status
        when 422
          raise Scrappybara::Errors::UnprocessableEntityError.new(error_body)
        else
          raise Scrappybara::Core::ApiError.new(status_code: response.status, body: error_body)
        end
      end
    end
  end
end 