# frozen_string_literal: true

module Scrappybara
  module Types
    class NotebookCell < BaseModel
      attr_accessor :id, :type, :content, :metadata, :outputs, :execution_count
    end
  end
end 