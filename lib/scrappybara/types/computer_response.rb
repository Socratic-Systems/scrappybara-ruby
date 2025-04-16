# frozen_string_literal: true

module Scrappybara
  module Types
    class ComputerResponse < BaseModel
      attr_accessor :output, :error, :base64_image, :system
    end
  end
end 