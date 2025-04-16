# frozen_string_literal: true

module Scrappybara
  module Types
    # Definition for authentication response
    class AuthResponse < BaseModel
      attr_accessor :auth_state_id, :name
    end
  end
end 