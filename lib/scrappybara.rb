# frozen_string_literal: true

require "zeitwerk"
require "faraday"
require "faraday/multipart"
require "faraday/retry"
require "json"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Scrappybara
  class Error < StandardError; end
  class ApiError < Error; end
  class UnprocessableEntityError < Error; end

  OMIT = Object.new.freeze

  class << self
    def new(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"], 
            timeout: nil, follow_redirects: true, faraday_client: nil)
      Client.new(
        base_url: base_url,
        environment: environment,
        api_key: api_key,
        timeout: timeout,
        follow_redirects: follow_redirects,
        faraday_client: faraday_client
      )
    end

    def async(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"], 
             timeout: nil, follow_redirects: true, faraday_client: nil)
      AsyncClient.new(
        base_url: base_url,
        environment: environment,
        api_key: api_key,
        timeout: timeout,
        follow_redirects: follow_redirects,
        faraday_client: faraday_client
      )
    end
  end
end

# Require the main components
require_relative "scrappybara/all"

loader.eager_load 