#!/usr/bin/env ruby
# frozen_string_literal: true

require "faraday"
require "json"

module Scrappybara
  class BaseClient
    attr_reader :client_wrapper

    def initialize(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"],
                  timeout: nil, follow_redirects: true, faraday_client: nil)
      raise Error, "API key is required" if api_key.nil?
      
      @client_wrapper = Core::ClientWrapper.new(
        base_url: base_url || environment,
        api_key: api_key,
        timeout: timeout,
        faraday_client: faraday_client
      )

      @instance = Instance::Client.new(client_wrapper: @client_wrapper)
      @browser = Browser::Client.new(client_wrapper: @client_wrapper)
      @code = Code::Client.new(client_wrapper: @client_wrapper)
      @notebook = Notebook::Client.new(client_wrapper: @client_wrapper)
      @env = Env::Client.new(client_wrapper: @client_wrapper)
    end

    def instance
      @instance
    end

    def browser
      @browser
    end

    def code
      @code
    end

    def notebook
      @notebook
    end

    def env
      @env
    end

    def start(instance_type:, timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      validate_instance_type(instance_type)
      
      response = @client_wrapper.http_client.request(
        path: "v1/start",
        method: :post,
        json: {
          instance_type: instance_type,
          timeout_hours: timeout_hours,
          blocked_domains: blocked_domains,
          resolution: resolution
        },
        request_options: request_options,
        omit: OMIT
      )
      
      handle_response(response, code: 200)
    end
    
    def get_instance(instance_id, request_options: nil)
      response = @client_wrapper.http_client.request(
        path: "v1/instance/#{instance_id}",
        method: :get,
        request_options: request_options
      )
      
      handle_response(response, code: 200)
    end
    
    def get_instances(request_options: nil)
      response = @client_wrapper.http_client.request(
        path: "v1/instances",
        method: :get,
        request_options: request_options
      )
      
      handle_response(response, code: 200)
    end
    
    def get_auth_states(request_options: nil)
      response = @client_wrapper.http_client.request(
        path: "v1/auth_states",
        method: :get,
        request_options: request_options
      )
      
      handle_response(response, code: 200)
    end

    private

    def validate_instance_type(instance_type)
      valid_types = ["ubuntu", "browser", "windows"]
      unless valid_types.include?(instance_type)
        raise ArgumentError, "instance_type must be one of #{valid_types.join(', ')}"
      end
    end

    def handle_response(response, code: 200)
      if response.status == code
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
        raise Errors::UnprocessableEntityError.new(error_body)
      else
        raise Core::ApiError.new(status_code: response.status, body: error_body)
      end
    end
  end

  class AsyncBaseClient
    attr_reader :client_wrapper

    def initialize(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"],
                  timeout: nil, follow_redirects: true, faraday_client: nil)
      raise Error, "API key is required" if api_key.nil?
      
      @client_wrapper = Core::AsyncClientWrapper.new(
        base_url: base_url || environment,
        api_key: api_key,
        timeout: timeout,
        faraday_client: faraday_client
      )

      @instance = Instance::AsyncClient.new(client_wrapper: @client_wrapper)
      @browser = Browser::AsyncClient.new(client_wrapper: @client_wrapper)
      @code = Code::AsyncClient.new(client_wrapper: @client_wrapper)
      @notebook = Notebook::AsyncClient.new(client_wrapper: @client_wrapper)
      @env = Env::AsyncClient.new(client_wrapper: @client_wrapper)
    end

    def instance
      @instance
    end

    def browser
      @browser
    end

    def code
      @code
    end

    def notebook
      @notebook
    end

    def env
      @env
    end

    def start(instance_type:, timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      validate_instance_type(instance_type)
      
      Core::AsyncResponse.new do
        response = @client_wrapper.http_client.request(
          path: "v1/start",
          method: :post,
          json: {
            instance_type: instance_type,
            timeout_hours: timeout_hours,
            blocked_domains: blocked_domains,
            resolution: resolution
          },
          request_options: request_options,
          omit: OMIT
        )
        
        handle_response(response, code: 200)
      end
    end
    
    def get_instance(instance_id, request_options: nil)
      Core::AsyncResponse.new do
        response = @client_wrapper.http_client.request(
          path: "v1/instance/#{instance_id}",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response, code: 200)
      end
    end
    
    def get_instances(request_options: nil)
      Core::AsyncResponse.new do
        response = @client_wrapper.http_client.request(
          path: "v1/instances",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response, code: 200)
      end
    end
    
    def get_auth_states(request_options: nil)
      Core::AsyncResponse.new do
        response = @client_wrapper.http_client.request(
          path: "v1/auth_states",
          method: :get,
          request_options: request_options
        )
        
        handle_response(response, code: 200)
      end
    end

    private

    def validate_instance_type(instance_type)
      valid_types = ["ubuntu", "browser", "windows"]
      unless valid_types.include?(instance_type)
        raise ArgumentError, "instance_type must be one of #{valid_types.join(', ')}"
      end
    end

    def handle_response(response, code: 200)
      if response.status == code
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
        raise Errors::UnprocessableEntityError.new(error_body)
      else
        raise Core::ApiError.new(status_code: response.status, body: error_body)
      end
    end
  end

  # Simple AsyncResponse class to match the core AsyncResponse
  class AsyncResponse
    def initialize(&block)
      @block = block
    end

    def await
      @block.call
    end
  end
end 