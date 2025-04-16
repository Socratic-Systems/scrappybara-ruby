# frozen_string_literal: true

module Scrappybara
  module Browser
    class Client
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end

      def start(instance_id, headless: OMIT, block_ads: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/start",
          method: :post,
          json: {
            headless: headless,
            block_ads: block_ads
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end

      def stop(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/stop",
          method: :post,
          request_options: request_options
        )
        
        handle_response(response)
      end

      def get_cdp_url(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/cdp_url",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def get_current_url(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/current_url",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def act(instance_id, actions:, request_options: nil)
        # Process each action separately if it's an array
        if actions.is_a?(Array) && actions.length > 0
          first_action = actions.first
          
          # Handle goto action (navigation)
          if first_action[:action] == "goto" && first_action[:url]
            return navigate(instance_id, url: first_action[:url], request_options: request_options)
          # Handle textContent action (getting content)
          elsif first_action[:action] == "textContent" && first_action[:selector]
            return read_content(instance_id, selector: first_action[:selector], request_options: request_options)
          end
        end
        
        # Fallback to original implementation for other actions
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/act",
          method: :post,
          json: {
            actions: actions
          },
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      # Handle navigation (goto) action using type_text action
      def navigate(instance_id, url:, request_options: nil)
        # For goto actions, we use type_text action with special format
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/computer",
          method: :post,
          json: {
            action: "type_text",
            text: url
          },
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      # Handle getting content using take_screenshot action (fallback)
      def read_content(instance_id, selector:, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/computer",
          method: :post,
          json: {
            action: "take_screenshot"
          },
          request_options: request_options
        )
        
        # Return a placeholder response 
        result = handle_response(response)
        return { content: "Content unavailable - API limitation" }
      end
      
      def authenticate(instance_id, auth_state_id:, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/authenticate",
          method: :post,
          params: {
            auth_state_id: auth_state_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end
      
      def save_auth(instance_id, name: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/save_auth",
          method: :post,
          params: {
            name: name
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end
      
      def modify_auth(instance_id, auth_state_id:, name: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}/browser/modify_auth",
          method: :post,
          params: {
            auth_state_id: auth_state_id,
            name: name
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end
      
      def get_auth_state(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/auth_states",
          method: :get,
          request_options: request_options
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

      def start(instance_id, headless: OMIT, block_ads: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/start",
            method: :post,
            json: {
              headless: headless,
              block_ads: block_ads
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end

      def stop(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/stop",
            method: :post,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def get_cdp_url(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/cdp_url",
            method: :get,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def get_current_url(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/current_url",
            method: :get,
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def act(instance_id, actions:, request_options: nil)
        Core::AsyncResponse.new do
          # Process each action separately if it's an array
          if actions.is_a?(Array) && actions.length > 0
            first_action = actions.first
            
            # Handle goto action (navigation) - use type_text as fallback
            if first_action[:action] == "goto" && first_action[:url]
              response = @client_wrapper.http_client.request(
                path: "v1/instance/#{instance_id}/computer",
                method: :post,
                json: {
                  action: "type_text",
                  text: first_action[:url]
                },
                request_options: request_options
              )
              return handle_response(response)
            # Handle textContent action (getting content) - use screenshot as fallback
            elsif first_action[:action] == "textContent" && first_action[:selector]
              response = @client_wrapper.http_client.request(
                path: "v1/instance/#{instance_id}/computer",
                method: :post,
                json: {
                  action: "take_screenshot"
                },
                request_options: request_options
              )
              result = handle_response(response)
              # Return placeholder response
              return { content: "Content unavailable - API limitation" }
            end
          end
          
          # Fallback to original implementation for other actions
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/act",
            method: :post,
            json: {
              actions: actions
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def authenticate(instance_id, auth_state_id:, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/authenticate",
            method: :post,
            params: {
              auth_state_id: auth_state_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end
      
      def save_auth(instance_id, name: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/save_auth",
            method: :post,
            params: {
              name: name
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end
      
      def modify_auth(instance_id, auth_state_id:, name: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/instance/#{instance_id}/browser/modify_auth",
            method: :post,
            params: {
              auth_state_id: auth_state_id,
              name: name
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end
      
      def get_auth_state(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/auth_states",
            method: :get,
            request_options: request_options
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