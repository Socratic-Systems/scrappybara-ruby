# frozen_string_literal: true

module Scrappybara
  # Helper module for browser operations
  module Browser
    # Start a new browser session
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param width [Integer] The width of the browser window (optional)
    # @param height [Integer] The height of the browser window (optional)
    # @param headless [Boolean] Whether to run in headless mode (optional)
    # @param browser [String] The browser to use (optional)
    # @param timezone [String] The timezone to use (optional)
    # @param locale [String] The locale to use (optional)
    # @param user_agent [String] The user agent to use (optional)
    # @param viewport_type [String] The viewport type to use (optional)
    # @param options [Hash] Additional options to pass to the browser
    #
    # @return [Hash] Response containing browser session information
    def self.start(client, width: nil, height: nil, headless: nil, browser: nil, 
                  timezone: nil, locale: nil, user_agent: nil, viewport_type: nil, **options)
      params = {
        width: width,
        height: height,
        headless: headless,
        browser: browser,
        timezone: timezone,
        locale: locale, 
        user_agent: user_agent,
        viewport_type: viewport_type
      }.compact

      # Merge any additional options
      params.merge!(options) if options.any?
      
      browser_client = client.browser
      browser_client.start(params)
    end

    # Stop a browser session
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    #
    # @return [Hash] Response indicating success
    def self.stop(client)
      client.browser.stop
    end

    # Get the CDP URL for a browser session
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    #
    # @return [Hash] Response containing the CDP URL
    def self.get_cdp_url(client)
      client.browser.get_cdp_url
    end

    # Get the current URL of the browser
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    #
    # @return [Hash] Response containing the current URL
    def self.get_current_url(client)
      client.browser.get_current_url
    end

    # Authenticate with the browser
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param domain [String] The domain to authenticate for
    # @param credentials [Hash] The credentials to use
    #
    # @return [Hash] Response indicating success
    def self.authenticate(client, domain, credentials)
      client.browser.authenticate(domain: domain, credentials: credentials)
    end

    # Save authentication state
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param name [String] The name to save the auth state as
    #
    # @return [Hash] Response containing the auth state
    def self.save_auth(client, name)
      client.browser.save_auth(name: name)
    end

    # Modify authentication state
    #
    # @param client [Scrappybara::Client] The Scrappybara client
    # @param name [String] The name of the auth state to modify
    # @param operations [Array] The operations to perform
    #
    # @return [Hash] Response indicating success
    def self.modify_auth(client, name, operations)
      client.browser.modify_auth(name: name, operations: operations)
    end
  end
end 