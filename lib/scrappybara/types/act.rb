# frozen_string_literal: true

module Scrappybara
  module Types
    # Act module namespace for Zeitwerk autoloader
    module Act
      # This empty module just serves as a namespace
    end
    
    # Base class for message parts
    class MessagePart < BaseModel
      attr_accessor :type
    end
    
    # Text part in a message
    class TextPart < MessagePart
      attr_accessor :text
      
      def initialize(text)
        @type = "text"
        @text = text
      end
    end
    
    # Image part in a message
    class ImagePart < MessagePart
      attr_accessor :image, :mime_type
      
      def initialize(image, mime_type: nil)
        @type = "image"
        @image = image
        @mime_type = mime_type
      end
    end
    
    # Tool call part in a message
    class ToolCallPart < MessagePart
      attr_accessor :id, :tool_call_id, :tool_name, :safety_checks, :args
      
      def initialize(tool_call_id, tool_name, args, id: nil, safety_checks: nil)
        @type = "tool-call"
        @id = id
        @tool_call_id = tool_call_id
        @tool_name = tool_name
        @safety_checks = safety_checks
        @args = args
      end
    end
    
    # Tool result part in a message
    class ToolResultPart < MessagePart
      attr_accessor :tool_call_id, :tool_name, :result, :is_error
      
      def initialize(tool_call_id, tool_name, result, is_error: false)
        @type = "tool-result"
        @tool_call_id = tool_call_id
        @tool_name = tool_name
        @result = result
        @is_error = is_error
      end
    end
    
    # Reasoning part in a message
    class ReasoningPart < MessagePart
      attr_accessor :id, :reasoning, :signature, :instructions
      
      def initialize(reasoning, id: nil, signature: nil, instructions: nil)
        @type = "reasoning"
        @id = id
        @reasoning = reasoning
        @signature = signature
        @instructions = instructions
      end
    end
    
    # Base class for messages
    class Message < BaseModel
      attr_accessor :role, :content
    end
    
    # User message
    class UserMessage < Message
      def initialize(content)
        @role = "user"
        @content = content
      end
    end
    
    # Assistant message
    class AssistantMessage < Message
      attr_accessor :response_id
      
      def initialize(content, response_id: nil)
        @role = "assistant"
        @content = content
        @response_id = response_id
      end
    end
    
    # Tool message
    class ToolMessage < Message
      def initialize(content)
        @role = "tool"
        @content = content
      end
    end
    
    # Model definition
    class AIModel < BaseModel
      attr_accessor :provider, :name, :api_key
      
      def initialize(provider, name, api_key: nil)
        @provider = provider
        @name = name
        @api_key = api_key
      end
    end
    
    # Token usage statistics
    class TokenUsage < BaseModel
      attr_accessor :prompt_tokens, :completion_tokens, :total_tokens
      
      def initialize(prompt_tokens, completion_tokens, total_tokens)
        @prompt_tokens = prompt_tokens
        @completion_tokens = completion_tokens
        @total_tokens = total_tokens
      end
    end
    
    # Single ACT request
    class SingleActRequest < BaseModel
      attr_accessor :model, :system, :messages, :tools, :temperature, :max_tokens
      
      def initialize(model, system: nil, messages: nil, tools: nil, temperature: nil, max_tokens: nil)
        @model = model
        @system = system
        @messages = messages
        @tools = tools
        @temperature = temperature
        @max_tokens = max_tokens
      end
    end
    
    # Single ACT response
    class SingleActResponse < BaseModel
      attr_accessor :message, :finish_reason, :usage
      
      def initialize(message, finish_reason, usage: nil)
        @message = message
        @finish_reason = finish_reason
        @usage = usage
      end
    end
    
    # Step in an ACT process
    class Step < BaseModel
      attr_accessor :text, :response_id, :reasoning_parts, :tool_calls, :tool_results, 
                   :finish_reason, :usage
      
      def initialize(text, response_id: nil, reasoning_parts: nil, tool_calls: nil, 
                    tool_results: nil, finish_reason: nil, usage: nil)
        @text = text
        @response_id = response_id
        @reasoning_parts = reasoning_parts
        @tool_calls = tool_calls
        @tool_results = tool_results
        @finish_reason = finish_reason
        @usage = usage
      end
    end
    
    # ACT response
    class ActResponse < BaseModel
      attr_accessor :messages, :steps, :text, :output, :usage
      
      def initialize(messages, steps, output, text: nil, usage: nil)
        @messages = messages
        @steps = steps
        @text = text
        @output = output
        @usage = usage
      end
    end
  end
end 