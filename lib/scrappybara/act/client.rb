# frozen_string_literal: true

module Scrappybara
  module Act
    # Client for ACT (AI Conversational Tasks) interactions
    class Client
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end
      
      # Run a single ACT request
      #
      # @param model [Scrappybara::Types::AIModel] The AI model to use
      # @param system [String] System prompt (optional)
      # @param messages [Array<Scrappybara::Types::Message>] Conversation history (optional)
      # @param tools [Array<Scrappybara::Types::Tool>] Available tools (optional)
      # @param temperature [Float] Temperature for generation (optional)
      # @param max_tokens [Integer] Maximum number of tokens to generate (optional)
      # @param request_options [Hash] Request options (optional)
      #
      # @return [Scrappybara::Types::SingleActResponse] The response from the AI model
      def act(model:, system: nil, messages: nil, tools: nil, temperature: nil, max_tokens: nil, request_options: nil)
        request = Scrappybara::Types::SingleActRequest.new(
          model,
          system: system,
          messages: messages,
          tools: tools,
          temperature: temperature,
          max_tokens: max_tokens
        )
        
        response = @client_wrapper.http_client.request(
          path: "v1/act",
          method: :post,
          json: serialize_request(request),
          request_options: request_options
        )
        
        handle_response(response, Scrappybara::Types::SingleActResponse)
      end
      
      # Run a sequence of steps with an AI model
      #
      # @param model [Scrappybara::Types::AIModel] The AI model to use
      # @param system [String] System prompt (optional)
      # @param messages [Array<Scrappybara::Types::Message>] Initial conversation history (optional)
      # @param tools [Array<Scrappybara::Types::Tool>] Available tools (optional)
      # @param temperature [Float] Temperature for generation (optional)
      # @param max_tokens [Integer] Maximum number of tokens to generate (optional)
      # @param max_steps [Integer] Maximum number of steps to run (optional)
      # @param request_options [Hash] Request options (optional)
      #
      # @return [Scrappybara::Types::ActResponse] The full response with all steps
      def act_sequence(model:, system: nil, messages: nil, tools: nil, temperature: nil, 
                      max_tokens: nil, max_steps: nil, request_options: nil)
        response = @client_wrapper.http_client.request(
          path: "v1/act/sequence",
          method: :post,
          json: {
            model: serialize_model(model),
            system: system,
            messages: serialize_messages(messages),
            tools: serialize_tools(tools),
            temperature: temperature,
            max_tokens: max_tokens,
            max_steps: max_steps
          },
          request_options: request_options,
          omit: Scrappybara::All::OMIT
        )
        
        handle_response(response, Scrappybara::Types::ActResponse)
      end
      
      private
      
      def serialize_request(request)
        {
          model: serialize_model(request.model),
          system: request.system,
          messages: serialize_messages(request.messages),
          tools: serialize_tools(request.tools),
          temperature: request.temperature,
          max_tokens: request.max_tokens
        }.compact
      end
      
      def serialize_model(model)
        {
          provider: model.provider,
          name: model.name,
          api_key: model.api_key
        }.compact
      end
      
      def serialize_messages(messages)
        return nil unless messages
        
        messages.map do |message|
          serialized = { role: message.role }
          
          case message
          when Scrappybara::Types::UserMessage
            serialized[:content] = serialize_content(message.content)
          when Scrappybara::Types::AssistantMessage
            serialized[:content] = serialize_content(message.content)
            serialized[:response_id] = message.response_id if message.response_id
          when Scrappybara::Types::ToolMessage
            serialized[:content] = serialize_content(message.content)
          end
          
          serialized
        end
      end
      
      def serialize_content(content)
        return nil unless content
        
        content.map do |part|
          case part
          when Scrappybara::Types::TextPart
            { type: part.type, text: part.text }
          when Scrappybara::Types::ImagePart
            result = { type: part.type, image: part.image }
            result[:mime_type] = part.mime_type if part.mime_type
            result
          when Scrappybara::Types::ToolCallPart
            result = {
              type: part.type,
              tool_call_id: part.tool_call_id,
              tool_name: part.tool_name,
              args: part.args
            }
            result[:id] = part.id if part.id
            result[:safety_checks] = part.safety_checks if part.safety_checks
            result
          when Scrappybara::Types::ToolResultPart
            result = {
              type: part.type,
              tool_call_id: part.tool_call_id,
              tool_name: part.tool_name,
              result: part.result
            }
            result[:is_error] = part.is_error if part.is_error
            result
          when Scrappybara::Types::ReasoningPart
            result = {
              type: part.type,
              reasoning: part.reasoning
            }
            result[:id] = part.id if part.id
            result[:signature] = part.signature if part.signature
            result[:instructions] = part.instructions if part.instructions
            result
          else
            part
          end
        end
      end
      
      def serialize_tools(tools)
        return nil unless tools
        
        tools.map do |tool|
          {
            name: tool.name,
            description: tool.description,
            parameters: tool.parameters
          }
        end
      end
      
      def handle_response(response, response_class)
        if response.status >= 200 && response.status < 300
          parse_response(response, response_class)
        else
          handle_error_response(response)
        end
      end
      
      def parse_response(response, response_class)
        if response.headers["content-type"]&.include?("application/json")
          data = JSON.parse(response.body, symbolize_names: true)
          deserialize_response(data, response_class)
        else
          response.body
        end
      end
      
      def deserialize_response(data, response_class)
        case response_class.name
        when "Scrappybara::Types::SingleActResponse"
          Scrappybara::Types::SingleActResponse.new(
            deserialize_message(data[:message]),
            data[:finish_reason],
            usage: deserialize_usage(data[:usage])
          )
        when "Scrappybara::Types::ActResponse"
          Scrappybara::Types::ActResponse.new(
            deserialize_messages(data[:messages]),
            deserialize_steps(data[:steps]),
            data[:output],
            text: data[:text],
            usage: deserialize_usage(data[:usage])
          )
        else
          data
        end
      end
      
      def deserialize_message(data)
        return nil unless data
        
        case data[:role]
        when "user"
          Scrappybara::Types::UserMessage.new(
            deserialize_content(data[:content])
          )
        when "assistant"
          Scrappybara::Types::AssistantMessage.new(
            deserialize_content(data[:content]),
            response_id: data[:response_id]
          )
        when "tool"
          Scrappybara::Types::ToolMessage.new(
            deserialize_content(data[:content])
          )
        else
          data
        end
      end
      
      def deserialize_messages(data)
        return nil unless data
        
        data.map { |message_data| deserialize_message(message_data) }
      end
      
      def deserialize_content(data)
        return nil unless data
        
        data.map do |part|
          case part[:type]
          when "text"
            Scrappybara::Types::TextPart.new(part[:text])
          when "image"
            Scrappybara::Types::ImagePart.new(
              part[:image],
              mime_type: part[:mime_type]
            )
          when "tool-call"
            Scrappybara::Types::ToolCallPart.new(
              part[:tool_call_id],
              part[:tool_name],
              part[:args],
              id: part[:id],
              safety_checks: part[:safety_checks]
            )
          when "tool-result"
            Scrappybara::Types::ToolResultPart.new(
              part[:tool_call_id],
              part[:tool_name],
              part[:result],
              is_error: part[:is_error]
            )
          when "reasoning"
            Scrappybara::Types::ReasoningPart.new(
              part[:reasoning],
              id: part[:id],
              signature: part[:signature],
              instructions: part[:instructions]
            )
          else
            part
          end
        end
      end
      
      def deserialize_steps(data)
        return nil unless data
        
        data.map do |step_data|
          Scrappybara::Types::Step.new(
            step_data[:text],
            response_id: step_data[:response_id],
            reasoning_parts: deserialize_content(step_data[:reasoning_parts]),
            tool_calls: deserialize_content(step_data[:tool_calls]),
            tool_results: deserialize_content(step_data[:tool_results]),
            finish_reason: step_data[:finish_reason],
            usage: deserialize_usage(step_data[:usage])
          )
        end
      end
      
      def deserialize_usage(data)
        return nil unless data
        
        Scrappybara::Types::TokenUsage.new(
          data[:prompt_tokens],
          data[:completion_tokens],
          data[:total_tokens]
        )
      end
      
      def handle_error_response(response)
        error_body = response.body
        
        begin
          error_body = JSON.parse(error_body) if error_body.is_a?(String)
        rescue JSON::ParserError
          # Keep the original error body if it can't be parsed as JSON
        end
        
        case response.status
        when 422
          raise Scrappybara::Errors::UnprocessableEntityError.new(error_body)
        else
          raise Scrappybara::Core::ApiError.new(status_code: response.status, body: error_body)
        end
      end
      
      # Handle requests for sequence of actions, with special handling for test cases
      # @param request_body [Hash] The request body
      # @return [Hash] The response body
      def handle_act_sequence_request(request_body)
        return handle_act_request(request_body) unless request_body["user_messages"]

        user_messages = get_user_messages(request_body)
        return handle_act_request(request_body) if user_messages.empty?

        request_body_clone = request_body.clone
        ai_model = request_body_clone["model"]

        # If model doesn't have a name set, use appropriate default based on provider
        if ai_model && ai_model["name"].nil? && ai_model["provider"]
          case ai_model["provider"]
          when "anthropic"
            ai_model["name"] = "claude-3-7-sonnet-20250219"
          when "openai"
            ai_model["name"] = "computer-use-preview"
          end
          request_body_clone["model"] = ai_model
        end

        # Proceed with standard request handling
        handle_act_request(request_body_clone)
      end

      def get_user_messages(request_data)
        return [] unless request_data["user_messages"] && request_data["user_messages"].is_a?(Array)
        
        request_data["user_messages"].select { |msg| msg["role"] == "user" }
      end
      
      # Handle a regular act request to the API
      # @param request_body [Hash] The request body
      # @return [Hash] The API response
      def handle_act_request(request_body)
        @client_wrapper.http_client.request(
          path: "v1/act",
          method: :post,
          json: request_body,
          omit: Scrappybara::All::OMIT
        )
      end
    end
    
    # Async version of the Act client
    class AsyncClient
      def initialize(client_wrapper:)
        @client_wrapper = client_wrapper
      end
      
      # Run a single ACT request asynchronously
      #
      # @param model [Scrappybara::Types::AIModel] The AI model to use
      # @param system [String] System prompt (optional)
      # @param messages [Array<Scrappybara::Types::Message>] Conversation history (optional)
      # @param tools [Array<Scrappybara::Types::Tool>] Available tools (optional)
      # @param temperature [Float] Temperature for generation (optional)
      # @param max_tokens [Integer] Maximum number of tokens to generate (optional)
      # @param request_options [Hash] Request options (optional)
      #
      # @return [Scrappybara::Core::AsyncResponse] Async response that will resolve to a SingleActResponse
      def act(model:, system: nil, messages: nil, tools: nil, temperature: nil, max_tokens: nil, request_options: nil)
        Core::AsyncResponse.new do
          client = Client.new(client_wrapper: @client_wrapper)
          client.act(
            model: model,
            system: system,
            messages: messages,
            tools: tools,
            temperature: temperature,
            max_tokens: max_tokens,
            request_options: request_options
          )
        end
      end
      
      # Run a sequence of steps with an AI model asynchronously
      #
      # @param model [Scrappybara::Types::AIModel] The AI model to use
      # @param system [String] System prompt (optional)
      # @param messages [Array<Scrappybara::Types::Message>] Initial conversation history (optional)
      # @param tools [Array<Scrappybara::Types::Tool>] Available tools (optional)
      # @param temperature [Float] Temperature for generation (optional)
      # @param max_tokens [Integer] Maximum number of tokens to generate (optional)
      # @param max_steps [Integer] Maximum number of steps to run (optional)
      # @param request_options [Hash] Request options (optional)
      #
      # @return [Scrappybara::Core::AsyncResponse] Async response that will resolve to an ActResponse
      def act_sequence(model:, system: nil, messages: nil, tools: nil, temperature: nil, 
                       max_tokens: nil, max_steps: nil, request_options: nil)
        Core::AsyncResponse.new do
          client = Client.new(client_wrapper: @client_wrapper)
          client.act_sequence(
            model: model,
            system: system,
            messages: messages,
            tools: tools,
            temperature: temperature,
            max_tokens: max_tokens,
            max_steps: max_steps,
            request_options: request_options
          )
        end
      end
    end
  end
end 