# frozen_string_literal: true

module Scrappybara
  module Types
    class BaseModel
      class << self
        def from_hash(hash)
          new(hash)
        end
      end

      def initialize(attributes = {})
        attributes = attributes.transform_keys(&:to_sym) if attributes.is_a?(Hash)
        set_attributes(attributes)
      end

      private

      def set_attributes(attributes)
        attributes.each do |key, value|
          instance_variable_set("@#{key}", value) if respond_to?("#{key}=")
        end
      end
    end
  end
end 