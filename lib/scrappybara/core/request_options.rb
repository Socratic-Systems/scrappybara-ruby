# frozen_string_literal: true

module Scrappybara
  module Core
    class RequestOptions
      attr_reader :timeout_in_seconds, :max_retries, :additional_headers, :additional_query_parameters

      def initialize(timeout_in_seconds: nil, max_retries: 0, additional_headers: {}, additional_query_parameters: {})
        @timeout_in_seconds = timeout_in_seconds
        @max_retries = max_retries
        @additional_headers = additional_headers || {}
        @additional_query_parameters = additional_query_parameters || {}
      end

      def to_hash
        {
          timeout_in_seconds: @timeout_in_seconds,
          max_retries: @max_retries,
          additional_headers: @additional_headers,
          additional_query_parameters: @additional_query_parameters
        }.compact
      end

      def [](key)
        to_hash[key]
      end

      def dig(*keys)
        to_hash.dig(*keys)
      end
    end
  end
end 