# frozen_string_literal: true

module Scrappybara
  module Notebook
    class Client
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end

      def list_kernels(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/kernels",
          method: :get,
          params: {
            instance_id: instance_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def list(instance_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/list",
          method: :get,
          params: {
            instance_id: instance_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def get(instance_id, notebook_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/get",
          method: :get,
          params: {
            instance_id: instance_id,
            notebook_id: notebook_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def create(instance_id, name:, kernel_name:, metadata: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/create",
          method: :post,
          json: {
            instance_id: instance_id,
            name: name,
            kernel_name: kernel_name,
            metadata: metadata
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end

      def delete(instance_id, notebook_id, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/delete",
          method: :delete,
          params: {
            instance_id: instance_id,
            notebook_id: notebook_id
          },
          request_options: request_options
        )
        
        handle_response(response)
      end

      def add_cell(instance_id, notebook_id, type:, content:, metadata: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/add_cell",
          method: :post,
          json: {
            instance_id: instance_id,
            notebook_id: notebook_id,
            type: type,
            content: content,
            metadata: metadata
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end

      def execute_cell(instance_id, notebook_id, cell_id, timeout: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/execute_cell",
          method: :post,
          json: {
            instance_id: instance_id,
            notebook_id: notebook_id,
            cell_id: cell_id,
            timeout: timeout
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response)
      end

      def execute(instance_id, notebook_id, timeout: OMIT, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/notebook/execute",
          method: :post,
          json: {
            instance_id: instance_id,
            notebook_id: notebook_id,
            timeout: timeout
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
      
      def list_kernels(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/kernels",
            method: :get,
            params: {
              instance_id: instance_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def list(instance_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/list",
            method: :get,
            params: {
              instance_id: instance_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def get(instance_id, notebook_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/get",
            method: :get,
            params: {
              instance_id: instance_id,
              notebook_id: notebook_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def create(instance_id, name:, kernel_name:, metadata: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/create",
            method: :post,
            json: {
              instance_id: instance_id,
              name: name,
              kernel_name: kernel_name,
              metadata: metadata
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end

      def delete(instance_id, notebook_id, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/delete",
            method: :delete,
            params: {
              instance_id: instance_id,
              notebook_id: notebook_id
            },
            request_options: request_options
          )
          
          handle_response(response)
        end
      end

      def add_cell(instance_id, notebook_id, type:, content:, metadata: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/add_cell",
            method: :post,
            json: {
              instance_id: instance_id,
              notebook_id: notebook_id,
              type: type,
              content: content,
              metadata: metadata
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end

      def execute_cell(instance_id, notebook_id, cell_id, timeout: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/execute_cell",
            method: :post,
            json: {
              instance_id: instance_id,
              notebook_id: notebook_id,
              cell_id: cell_id,
              timeout: timeout
            },
            request_options: request_options,
            omit: OMIT
          )
          
          handle_response(response)
        end
      end

      def execute(instance_id, notebook_id, timeout: OMIT, request_options: nil)
        Core::AsyncResponse.new do
          response = @client_wrapper.http_client.request(
            path: "v1/notebook/execute",
            method: :post,
            json: {
              instance_id: instance_id,
              notebook_id: notebook_id,
              timeout: timeout
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