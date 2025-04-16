# frozen_string_literal: true

module Scrappybara
  module Types
    class HttpValidationError < BaseModel
      attr_accessor :detail

      def to_s
        detail.to_s
      end
    end
  end
end 