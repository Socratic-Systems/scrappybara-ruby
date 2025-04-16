# frozen_string_literal: true

module Scrappybara
  module Types
    class BrowserAuthenticateResponse < BaseModel
      attr_accessor :success, :message
    end
  end
end 