# frozen_string_literal: true

module Scrappybara
  module Types
    # Definition for authentication state
    class AuthState < BaseModel
      attr_accessor :id, :name, :created_at, :updated_at
    end
  end
end 