# frozen_string_literal: true

# Base clients
require_relative "client"
require_relative "browser/client"
require_relative "instance/client"

# Type definitions
require_relative "types/auth_response"
require_relative "types/auth_state"
require_relative "types/computer_response"
require_relative "types/default_headers"
require_relative "types/tool"
require_relative "types/act"

# Tools
require_relative "tools"

# Helper modules
require_relative "browser"
require_relative "instance"

# ACT client
require_relative "act/client"

module Scrappybara
  # This module just serves as a namespace to satisfy the Zeitwerk autoloader
  module All
    # Define OMIT as a constant to be used for omitting parameters
    OMIT = Object.new.freeze
  end
end

require_relative 'version'
require_relative 'environment'
require_relative 'core/api_error'
require_relative 'core/file'
require_relative 'core/request_options'
require_relative 'core/client_wrapper'
require_relative 'core/http_client'
require_relative 'core/async_http_client'
require_relative 'errors/unprocessable_entity_error'
require_relative 'code/client'
require_relative 'notebook/client'
require_relative 'env/client'
require_relative 'base_client' 