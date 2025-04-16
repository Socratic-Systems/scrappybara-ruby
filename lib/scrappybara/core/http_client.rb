# frozen_string_literal: true

module Scrappybara
  module Core
    class HttpClient
      INITIAL_RETRY_DELAY_SECONDS = 0.5
      MAX_RETRY_DELAY_SECONDS = 10
      MAX_RETRY_DELAY_SECONDS_FROM_HEADER = 30

      attr_reader :faraday_client

      def initialize(faraday_client:, base_timeout:, base_headers:, base_url: nil)
        @faraday_client = faraday_client
        @base_timeout = base_timeout
        @base_headers = base_headers
        @base_url = base_url
      end

      def get_base_url(maybe_base_url)
        base_url = maybe_base_url
        base_url ||= @base_url.call if @base_url

        unless base_url
          raise ArgumentError, "A base_url is required to make this request, please provide one and try again."
        end

        base_url
      end

      def request(path: nil, method:, base_url: nil, params: nil, json: nil, 
                  data: nil, content: nil, files: nil, headers: nil, 
                  request_options: nil, retries: 2, omit: nil)
        base_url = get_base_url(base_url)
        timeout = request_options&.dig(:timeout_in_seconds) || @base_timeout.call

        json_body, data_body = get_request_body(json: json, data: data, request_options: request_options, omit: omit)

        request_headers = {
          **@base_headers.call,
          **(headers || {}),
          **(request_options&.dig(:additional_headers) || {})
        }.compact

        request_params = {
          **(params || {}),
          **(request_options&.dig(:additional_query_parameters) || {})
        }.compact

        if omit
          request_params = remove_omit_from_dict(request_params, omit)
        end

        full_url = URI.join("#{base_url}/", path.to_s).to_s

        response = @faraday_client.run_request(
          method.downcase.to_sym, 
          full_url,
          json_body || data_body || content,
          request_headers
        ) do |req|
          req.params.merge!(request_params) if request_params.any?
          req.options.timeout = timeout if timeout
          
          if files && files != omit
            files = remove_none_from_dict(files)
            files = remove_omit_from_dict(files, omit) if omit
            
            files.each do |key, file_obj|
              if file_obj.is_a?(Array)
                file_obj.each do |f|
                  req.body = add_file_to_body(req.body, key, f)
                end
              else
                req.body = add_file_to_body(req.body, key, file_obj)
              end
            end
          end
        end

        max_retries = request_options&.dig(:max_retries) || 0
        if should_retry?(response) && max_retries > retries
          sleep(retry_timeout(response: response, retries: retries))
          return request(
            path: path,
            method: method,
            base_url: base_url,
            params: params,
            json: json,
            data: data, 
            content: content,
            files: files,
            headers: headers,
            request_options: request_options,
            retries: retries + 1,
            omit: omit
          )
        end

        response
      end

      private

      def get_request_body(json: nil, data: nil, request_options: nil, omit: nil)
        json_body = nil
        data_body = nil

        if json && json != omit
          json_body = remove_none_from_dict(json)
          json_body = remove_omit_from_dict(json_body, omit) if omit
        end

        if data && data != omit
          data_body = remove_none_from_dict(data)
          data_body = remove_omit_from_dict(data_body, omit) if omit
        end

        [json_body, data_body]
      end

      def should_retry?(response)
        [429, 503].include?(response.status)
      end

      def retry_timeout(response:, retries:)
        retry_after = parse_retry_after(response.headers)
        
        if retry_after
          [retry_after, MAX_RETRY_DELAY_SECONDS_FROM_HEADER].min
        else
          jitter = Random.rand * 0.1
          backoff = [INITIAL_RETRY_DELAY_SECONDS * (2 ** retries), MAX_RETRY_DELAY_SECONDS].min
          backoff * (1 + jitter)
        end
      end

      def parse_retry_after(headers)
        retry_after_ms = headers["retry-after-ms"]
        if retry_after_ms
          begin
            return retry_after_ms.to_i / 1000.0 if retry_after_ms.to_i > 0
            return 0
          rescue
            # Fall through to retry-after header
          end
        end

        retry_after = headers["retry-after"]
        return nil unless retry_after

        # Try to parse as an integer (seconds)
        if retry_after =~ /^\s*\d+\s*$/
          seconds = retry_after.to_f
        else
          # Try to parse as a date
          begin
            retry_date = Time.httpdate(retry_after)
            seconds = retry_date - Time.now
          rescue
            return nil
          end
        end

        seconds = 0 if seconds < 0
        seconds
      end

      def remove_none_from_dict(hash)
        return hash unless hash.is_a?(Hash)
        hash.compact
      end

      def remove_omit_from_dict(hash, omit_value)
        return hash unless hash.is_a?(Hash)
        hash.reject { |_, v| v == omit_value }
      end

      def add_file_to_body(body, key, file)
        form_data = body || {}
        
        if file.respond_to?(:read)
          form_data[key] = Faraday::Multipart::FilePart.new(
            file.path,
            file.content_type || "application/octet-stream",
            file.filename
          )
        elsif file.is_a?(String)
          if File.file?(file)
            form_data[key] = Faraday::Multipart::FilePart.new(
              file,
              File.extname(file) == ".json" ? "application/json" : "application/octet-stream",
              File.basename(file)
            )
          else
            form_data[key] = file
          end
        elsif file.is_a?(Hash) && file[:content] && file[:filename]
          form_data[key] = Faraday::Multipart::FilePart.new(
            StringIO.new(file[:content]),
            file[:content_type] || "application/octet-stream",
            file[:filename]
          )
        end
        
        form_data
      end
    end
  end
end 