# frozen_string_literal: true

module Scrappybara
  module Types
    # Base class for all tools
    class Tool < BaseModel
      attr_accessor :name, :description, :parameters
      
      # Initialize a new tool
      #
      # @param name [String] The name of the tool
      # @param description [String] Description of what the tool does
      # @param parameters [Hash] Parameters schema for the tool
      def initialize(name:, description:, parameters:)
        @name = name
        @description = description
        @parameters = parameters
      end
      
      # Execute the tool with the given arguments
      #
      # @param kwargs [Hash] Arguments to pass to the tool
      #
      # @return [Object] The result of executing the tool
      def call(**kwargs)
        raise NotImplementedError, "Subclasses must implement the call method"
      end
      
      # Execute the tool by name and arguments
      #
      # @param tool_name [String] The name of the tool to execute
      # @param args [Hash] Arguments to pass to the tool
      # @param tools [Array<Tool>] Available tools to search
      #
      # @return [Hash] The result of executing the tool and metadata
      def self.execute_by_name(tool_name, args, tools)
        # Find the tool by name
        tool = tools.find { |t| t.name == tool_name }
        
        return { error: "Tool not found: #{tool_name}" } unless tool
        
        begin
          # Symbolize the keys in the args hash
          symbolized_args = {}
          args.each do |key, value|
            symbolized_args[key.to_sym] = value
          end
          
          # Call the tool with the args
          result = tool.call(**symbolized_args)
          
          { result: result }
        rescue => e
          { error: "Error executing tool: #{e.message}" }
        end
      end
    end
    
    # Tool that makes API calls
    class ApiTool < Tool
      attr_accessor :api_reference
      
      # Initialize a new API tool
      #
      # @param name [String] The name of the tool
      # @param description [String] Description of what the tool does
      # @param parameters [Hash] Parameters schema for the tool
      # @param api_reference [String] Reference to the API documentation
      def initialize(name:, description:, parameters:, api_reference: nil)
        super(name: name, description: description, parameters: parameters)
        @api_reference = api_reference
      end
    end
    
    # Tool that executes a function
    class FunctionTool < Tool
      attr_accessor :function
      
      # Initialize a new function tool
      #
      # @param name [String] The name of the tool
      # @param description [String] Description of what the tool does
      # @param parameters [Hash] Parameters schema for the tool
      # @param function [Proc] The function to execute
      def initialize(name:, description:, parameters:, function:)
        super(name: name, description: description, parameters: parameters)
        @function = function
      end
      
      # Execute the function with the given arguments
      #
      # @param kwargs [Hash] Arguments to pass to the function
      #
      # @return [Object] The result of executing the function
      def call(**kwargs)
        @function.call(**kwargs)
      end
    end
  end
end 