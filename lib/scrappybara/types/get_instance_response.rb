# frozen_string_literal: true

module Scrappybara
  module Types
    class GetInstanceResponse < BaseModel
      attr_accessor :id, :launch_time, :instance_type, :status, :resolution

      def initialize(attributes = {})
        super
        @launch_time = parse_datetime(@launch_time) if @launch_time.is_a?(String)
      end

      private

      def parse_datetime(datetime_str)
        Time.parse(datetime_str)
      rescue
        datetime_str
      end
    end
  end
end 