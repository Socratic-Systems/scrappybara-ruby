# frozen_string_literal: true

require "faraday"
require "faraday/retry"

module Scrappybara
  module Core
    class BaseClientWrapper
      def initialize(api_key:, base_url:, timeout: nil)
        @api_key = api_key
        @base_url = base_url
        @timeout = timeout
      end

      def get_headers
        {
          "x-api-key" => @api_key,
          "User-Agent" => "scrappybara-ruby/#{Scrappybara::VERSION}"
        }
      end

      def get_timeout
        @timeout
      end

      def get_base_url
        @base_url
      end
    end

    class ClientWrapper < BaseClientWrapper
      attr_reader :http_client

      def initialize(api_key:, base_url:, timeout: nil, faraday_client: nil)
        super(api_key: api_key, base_url: base_url, timeout: timeout)
        
        @http_client = HttpClient.new(
          faraday_client: faraday_client || create_default_client(timeout),
          base_headers: -> { get_headers },
          base_timeout: -> { get_timeout },
          base_url: -> { get_base_url }
        )
      end

      private

      def create_default_client(timeout)
        Faraday.new do |f|
          f.request :json
          f.request :multipart
          f.request :retry, max: 2, retry_statuses: [429, 503]
          f.adapter Faraday.default_adapter
          f.options.timeout = timeout || 600
        end
      end
    end

    class AsyncClientWrapper < BaseClientWrapper
      attr_reader :http_client

      def initialize(api_key:, base_url:, timeout: nil, faraday_client: nil)
        super(api_key: api_key, base_url: base_url, timeout: timeout)
        
        # Note: Ruby doesn't have built-in async HTTP clients like Python's httpx.AsyncClient
        # We'll implement this with promises or async patterns in a real implementation
        # For now, we'll use the same client but wrap responses in a Promise-like object
        @http_client = AsyncHttpClient.new(
          faraday_client: faraday_client || create_default_client(timeout),
          base_headers: -> { get_headers },
          base_timeout: -> { get_timeout },
          base_url: -> { get_base_url }
        )
      end

      private

      def create_default_client(timeout)
        Faraday.new do |f|
          f.request :json
          f.request :multipart
          f.request :retry, max: 2, retry_statuses: [429, 503]
          f.adapter Faraday.default_adapter
          f.options.timeout = timeout || 600
        end
      end
    end
  end
end 