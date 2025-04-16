# frozen_string_literal: true

module Scrappybara
  module Core
    class File
      attr_reader :content, :content_type, :filename

      def initialize(content, filename, content_type = nil)
        @content = content
        @filename = filename
        @content_type = content_type || detect_content_type(filename)
      end

      def to_faraday_file_part
        Faraday::Multipart::FilePart.new(
          StringIO.new(@content),
          @content_type,
          @filename
        )
      end

      private

      def detect_content_type(filename)
        ext = ::File.extname(filename).downcase
        case ext
        when ".json"
          "application/json"
        when ".txt"
          "text/plain"
        when ".png"
          "image/png"
        when ".jpg", ".jpeg"
          "image/jpeg"
        when ".pdf"
          "application/pdf"
        else
          "application/octet-stream"
        end
      end
    end
  end
end 