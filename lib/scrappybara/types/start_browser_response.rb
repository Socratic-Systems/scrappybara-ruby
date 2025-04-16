# frozen_string_literal: true

module Scrappybara
  module Types
    class StartBrowserResponse < BaseModel
      attr_accessor :success, :message
    end
  end
end 