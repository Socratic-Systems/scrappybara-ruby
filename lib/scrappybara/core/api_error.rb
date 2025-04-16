# frozen_string_literal: true

module Scrappybara
  module Core
    class ApiError < Scrappybara::Error
      attr_reader :status_code, :body

      def initialize(status_code: nil, body: nil)
        @status_code = status_code
        @body = body
        
        message = "API Error"
        message += " (#{status_code})" if status_code
        message += ": #{body}" if body

        super(message)
      end
    end
  end
end 