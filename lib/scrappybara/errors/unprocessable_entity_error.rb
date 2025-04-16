# frozen_string_literal: true

module Scrappybara
  module Errors
    class UnprocessableEntityError < Scrappybara::Error
      attr_reader :validation_error

      def initialize(validation_error)
        @validation_error = validation_error
        super("Validation error: #{validation_error}")
      end
    end
  end
end 