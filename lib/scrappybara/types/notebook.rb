# frozen_string_literal: true

module Scrappybara
  module Types
    class Notebook < BaseModel
      attr_accessor :id, :name, :kernel_name, :cells, :metadata
    end
  end
end