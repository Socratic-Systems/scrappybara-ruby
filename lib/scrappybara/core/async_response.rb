# frozen_string_literal: true

module Scrappybara
  module Core
    class AsyncResponse
      def initialize(&block)
        @block = block
      end

      def await
        @block.call
      end
    end
  end
end 