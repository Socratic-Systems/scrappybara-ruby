# frozen_string_literal: true

module Scrappybara
  module Types
    class UploadResponse < BaseModel
      attr_accessor :filename, :path, :media_type
    end
  end
end