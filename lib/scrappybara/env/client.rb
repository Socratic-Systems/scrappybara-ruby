# frozen_string_literal: true

module Scrappybara
  module Env
    class Client
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end

      def set(instance_id, variables:, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/env/set",
          method: :post,
          json: {
            instance_id: instance_id,
            variables: variables
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def get(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/env/get",
          method: :get,
          params: {
            instance_id: instance_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def delete(instance_id, keys:, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/env/delete",
          method: :delete,
          json: {
            instance_id: instance_id,
            keys: keys
          },
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

      def set(instance_id, variables:, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/env/set",
            method: :post,
            json: {
              instance_id: instance_id,
              variables: variables
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def get(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/env/get",
            method: :get,
            params: {
              instance_id: instance_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def delete(instance_id, keys:, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/env/delete",
            method: :delete,
            json: {
              instance_id: instance_id,
              keys: keys
            },
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