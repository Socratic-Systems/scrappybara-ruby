# frozen_string_literal: true

module Scrappybara
  # The main Scrappybara client class
  class Client
    attr_reader :base_client
    
    def initialize(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"],
                  timeout: nil, follow_redirects: true, faraday_client: nil)
      @base_client = BaseClient.new(
        base_url: base_url,
        environment: environment,
        api_key: api_key,
        timeout: timeout,
        follow_redirects: follow_redirects,
        faraday_client: faraday_client
      )
    end

    def http_client
      @base_client.client_wrapper.http_client
    end

    # Create a computer tool for this client
    #
    # @return [Scrappybara::Tools::ComputerTool] A computer tool instance
    def computer
      Tools::ComputerTool.new(self)
    end
    
    # Create an edit tool for this client
    #
    # @return [Scrappybara::Tools::EditTool] An edit tool instance
    def edit
      Tools::EditTool.new(self)
    end
    
    # Create a bash tool for this client
    #
    # @return [Scrappybara::Tools::BashTool] A bash tool instance
    def bash
      Tools::BashTool.new(self)
    end
    
    # Access the AI client for AI interactions
    #
    # @return [Scrappybara::Act::Client] The Act client instance
    def ai
      @act_client ||= Act::Client.new(client_wrapper: @base_client.client_wrapper)
    end

    def start_ubuntu(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response = @base_client.start(
        instance_type: "ubuntu",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      UbuntuInstance.new(
        response[:id],
        response[:launch_time],
        response[:status],
        @base_client
      )
    end
    
    def start_browser(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response = @base_client.start(
        instance_type: "browser",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      BrowserInstance.new(
        response[:id],
        response[:launch_time],
        response[:status],
        @base_client
      )
    end

    def start_windows(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response = @base_client.start(
        instance_type: "windows",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      WindowsInstance.new(
        response[:id],
        response[:launch_time],
        response[:status],
        @base_client
      )
    end
    
    # For backward compatibility
    def start_chrome(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_browser(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    # For backward compatibility
    def start_firefox(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_browser(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    # For backward compatibility
    def start_jupyter(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_ubuntu(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    def authenticate(auth_state_id:, request_options: nil)
      @base_client.browser.authenticate(@id, auth_state_id: auth_state_id, request_options: request_options)
    end

    def get_auth_states(request_options: nil)
      response = @base_client.client_wrapper.http_client.request(
        path: "v1/auth_states",
        method: :get,
        request_options: request_options
      )
      
      if response.status >= 200 && response.status < 300
        if response.headers["content-type"]&.include?("application/json")
          JSON.parse(response.body, symbolize_names: true)
        else
          response.body
        end
      else
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
    end

    def act(actions:, request_options: nil)
      @base_client.browser.act(
        @id,
        actions: actions,
        request_options: request_options
      )
    end
  end

  # Async version of the main client
  class AsyncClient
    attr_reader :base_client
    
    def initialize(base_url: nil, environment: Environment::PRODUCTION, api_key: ENV["SCRAPYBARA_API_KEY"],
                  timeout: nil, follow_redirects: true, faraday_client: nil)
      @base_client = AsyncBaseClient.new(
        base_url: base_url,
        environment: environment,
        api_key: api_key,
        timeout: timeout,
        follow_redirects: follow_redirects,
        faraday_client: faraday_client
      )
    end

    def http_client
      @base_client.client_wrapper.http_client
    end

    # Create a computer tool for this client
    #
    # @return [Scrappybara::Tools::ComputerTool] A computer tool instance
    def computer
      Tools::ComputerTool.new(self)
    end
    
    # Create an edit tool for this client
    #
    # @return [Scrappybara::Tools::EditTool] An edit tool instance
    def edit
      Tools::EditTool.new(self)
    end
    
    # Create a bash tool for this client
    #
    # @return [Scrappybara::Tools::BashTool] A bash tool instance
    def bash
      Tools::BashTool.new(self)
    end
    
    # Access the AI client for AI interactions
    #
    # @return [Scrappybara::Act::AsyncClient] The async Act client instance
    def ai
      @act_client ||= Act::AsyncClient.new(client_wrapper: @base_client.client_wrapper)
    end

    def start_ubuntu(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response_promise = @base_client.start(
        instance_type: "ubuntu",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      Core::AsyncResponse.new do
        response = response_promise.await
        AsyncUbuntuInstance.new(
          response[:id],
          response[:launch_time],
          response[:status],
          @base_client
        )
      end
    end
    
    def start_browser(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response_promise = @base_client.start(
        instance_type: "browser",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      Core::AsyncResponse.new do
        response = response_promise.await
        AsyncBrowserInstance.new(
          response[:id],
          response[:launch_time],
          response[:status],
          @base_client
        )
      end
    end

    def start_windows(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      response_promise = @base_client.start(
        instance_type: "windows",
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
      
      Core::AsyncResponse.new do
        response = response_promise.await
        AsyncWindowsInstance.new(
          response[:id],
          response[:launch_time],
          response[:status],
          @base_client
        )
      end
    end
    
    # For backward compatibility
    def start_chrome(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_browser(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    # For backward compatibility
    def start_firefox(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_browser(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    # For backward compatibility
    def start_jupyter(timeout_hours: OMIT, blocked_domains: OMIT, resolution: OMIT, request_options: nil)
      start_ubuntu(
        timeout_hours: timeout_hours,
        blocked_domains: blocked_domains,
        resolution: resolution,
        request_options: request_options
      )
    end

    def authenticate(auth_state_id:, request_options: nil)
      @base_client.browser.authenticate(@id, auth_state_id: auth_state_id, request_options: request_options)
    end

    def get_auth_states(request_options: nil)
      response = @base_client.client_wrapper.http_client.request(
        path: "v1/auth_states",
        method: :get,
        request_options: request_options
      )
      
      if response.status >= 200 && response.status < 300
        if response.headers["content-type"]&.include?("application/json")
          JSON.parse(response.body, symbolize_names: true)
        else
          response.body
        end
      else
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
    end

    def act(actions:, request_options: nil)
      @base_client.browser.act(
        @id,
        actions: actions,
        request_options: request_options
      )
    end
  end

  # Base class for instance types
  class BaseInstance
    attr_reader :id, :launch_time, :status, :client

    def initialize(id, launch_time, status, client)
      @id = id
      @launch_time = launch_time
      @status = status
      @client = client
    end

    def stop(request_options: nil)
      @client.instance.stop(@id, request_options: request_options)
    end

    def get(request_options: nil)
      @client.instance.get(@id, request_options: request_options)
    end

    def screenshot(request_options: nil)
      @client.instance.screenshot(@id, request_options: request_options)
    end

    def get_stream_url(request_options: nil)
      @client.instance.get_stream_url(@id, request_options: request_options)
    end

    def upload(path, file, request_options: nil)
      @client.instance.upload(@id, path: path, file: file, request_options: request_options)
    end

    def bash(command, wait: OMIT, request_options: nil)
      @client.instance.bash(@id, command: command, wait: wait, request_options: request_options)
    end

    def file(command, file_path: OMIT, request_options: nil)
      @client.instance.file(@id, command: command, file_path: file_path, request_options: request_options)
    end

    def computer(command, request_options: nil)
      @client.instance.computer(@id, command: command, request_options: request_options)
    end

    def env
      EnvHelper.new(@id, @client)
    end
  end

  # Base class for async instance types
  class AsyncBaseInstance
    attr_reader :id, :launch_time, :status, :client

    def initialize(id, launch_time, status, client)
      @id = id
      @launch_time = launch_time
      @status = status
      @client = client
    end

    def stop(request_options: nil)
      @client.instance.stop(@id, request_options: request_options)
    end

    def get(request_options: nil)
      @client.instance.get(@id, request_options: request_options)
    end

    def screenshot(request_options: nil)
      @client.instance.screenshot(@id, request_options: request_options)
    end

    def get_stream_url(request_options: nil)
      @client.instance.get_stream_url(@id, request_options: request_options)
    end

    def upload(path, file, request_options: nil)
      @client.instance.upload(@id, path: path, file: file, request_options: request_options)
    end

    def bash(command, wait: OMIT, request_options: nil)
      @client.instance.bash(@id, command: command, wait: wait, request_options: request_options)
    end

    def file(command, file_path: OMIT, request_options: nil)
      @client.instance.file(@id, command: command, file_path: file_path, request_options: request_options)
    end

    def computer(command, request_options: nil)
      @client.instance.computer(@id, command: command, request_options: request_options)
    end

    def env
      AsyncEnvHelper.new(@id, @client)
    end
  end

  # Ubuntu instance implementation
  class UbuntuInstance < BaseInstance
    def browser
      InstanceBrowser.new(@id, @client)
    end
  end

  # Browser instance implementation (was ChromeInstance before)
  class BrowserInstance < BaseInstance
    def browser
      InstanceBrowser.new(@id, @client)
    end

    def start_browser(headless: OMIT, block_ads: OMIT, request_options: nil)
      @client.browser.start(@id, headless: headless, block_ads: block_ads, request_options: request_options)
    end

    def stop_browser(request_options: nil)
      @client.browser.stop(@id, request_options: request_options)
    end

    def get_cdp_url(request_options: nil)
      @client.browser.get_cdp_url(@id, request_options: request_options)
    end

    def get_current_url(request_options: nil)
      @client.browser.get_current_url(@id, request_options: request_options)
    end

    def act(actions, request_options: nil)
      @client.browser.act(@id, actions: actions, request_options: request_options)
    end

    def authenticate(auth_state_id:, request_options: nil)
      @client.browser.authenticate(@id, auth_state_id: auth_state_id, request_options: request_options)
    end

    def modify_auth(auth_state_id:, name: OMIT, request_options: nil)
      @client.browser.modify_auth(
        @id, 
        auth_state_id: auth_state_id, 
        name: name, 
        request_options: request_options
      )
    end

    def get_auth_state(request_options: nil)
      @client.browser.get_auth_state(@id, request_options: request_options)
    end

    def save_auth(name: OMIT, request_options: nil)
      @client.browser.save_auth(@id, name: name, request_options: request_options)
    end
  end
  
  # For backward compatibility
  class ChromeInstance < BrowserInstance
  end
  
  # For backward compatibility
  class FirefoxInstance < BrowserInstance
  end

  # Windows instance implementation
  class WindowsInstance < BaseInstance
  end

  # For backward compatibility  
  class JupyterInstance < UbuntuInstance
    def code
      CodeHelper.new(@id, @client)
    end

    def notebook
      NotebookHelper.new(@id, @client)
    end
  end

  # Async Ubuntu instance implementation
  class AsyncUbuntuInstance < AsyncBaseInstance
    def browser
      InstanceBrowser.new(@id, @client)
    end
  end

  # Async Browser instance implementation
  class AsyncBrowserInstance < AsyncBaseInstance
    def browser
      InstanceBrowser.new(@id, @client)
    end

    def start_browser(headless: OMIT, block_ads: OMIT, request_options: nil)
      @client.browser.start(@id, headless: headless, block_ads: block_ads, request_options: request_options)
    end

    def stop_browser(request_options: nil)
      @client.browser.stop(@id, request_options: request_options)
    end

    def get_cdp_url(request_options: nil)
      @client.browser.get_cdp_url(@id, request_options: request_options)
    end

    def get_current_url(request_options: nil)
      @client.browser.get_current_url(@id, request_options: request_options)
    end

    def act(actions, request_options: nil)
      @client.browser.act(@id, actions: actions, request_options: request_options)
    end

    def authenticate(auth_state_id:, request_options: nil)
      @client.browser.authenticate(@id, auth_state_id: auth_state_id, request_options: request_options)
    end

    def modify_auth(auth_state_id:, name: OMIT, request_options: nil)
      @client.browser.modify_auth(
        @id, 
        auth_state_id: auth_state_id, 
        name: name, 
        request_options: request_options
      )
    end

    def get_auth_state(request_options: nil)
      @client.browser.get_auth_state(@id, request_options: request_options)
    end

    def save_auth(name: OMIT, request_options: nil)
      @client.browser.save_auth(@id, name: name, request_options: request_options)
    end
  end
  
  # For backward compatibility
  class AsyncChromeInstance < AsyncBrowserInstance
  end
  
  # For backward compatibility
  class AsyncFirefoxInstance < AsyncBrowserInstance
  end

  # Async Windows instance implementation
  class AsyncWindowsInstance < AsyncBaseInstance
  end
  
  # For backward compatibility
  class AsyncJupyterInstance < AsyncUbuntuInstance
    def code
      AsyncCodeHelper.new(@id, @client)
    end

    def notebook
      AsyncNotebookHelper.new(@id, @client)
    end
  end
  
  # Browser helper class - REPLACE THIS
  class BrowserHelperWrapper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end
    
    def start(request_options: nil)
      @client.browser.start(@instance_id, request_options: request_options)
    end
    
    def stop(request_options: nil)
      @client.browser.stop(@instance_id, request_options: request_options)
    end
    
    def get_cdp_url(request_options: nil)
      @client.browser.get_cdp_url(@instance_id, request_options: request_options)
    end
    
    def get_current_url(request_options: nil)
      @client.browser.get_current_url(@instance_id, request_options: request_options)
    end
    
    def save_auth(name: OMIT, request_options: nil)
      @client.browser.save_auth(@instance_id, name: name, request_options: request_options)
    end
    
    def modify_auth(auth_state_id:, name: OMIT, request_options: nil)
      @client.browser.modify_auth(
        @instance_id, 
        auth_state_id: auth_state_id, 
        name: name, 
        request_options: request_options
      )
    end
    
    def authenticate(auth_state_id:, request_options: nil)
      @client.browser.authenticate(
        @instance_id,
        auth_state_id: auth_state_id,
        request_options: request_options
      )
    end
    
    def act(actions:, request_options: nil)
      @client.browser.act(
        @instance_id,
        actions: actions,
        request_options: request_options
      )
    end
  end

  # Browser helper class
  class BrowserHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def act(actions, request_options: nil)
      @client.browser.act(@instance_id, actions: actions, request_options: request_options)
    end
  end

  # Python-style Browser class equivalent
  class InstanceBrowser
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end
    
    def start(request_options: nil)
      @client.browser.start(@instance_id, request_options: request_options)
    end
    
    def stop(request_options: nil)
      @client.browser.stop(@instance_id, request_options: request_options)
    end
    
    def get_cdp_url(request_options: nil)
      @client.browser.get_cdp_url(@instance_id, request_options: request_options)
    end
    
    def get_current_url(request_options: nil)
      @client.browser.get_current_url(@instance_id, request_options: request_options)
    end
    
    def save_auth(name: OMIT, request_options: nil)
      @client.browser.save_auth(@instance_id, name: name, request_options: request_options)
    end
    
    def modify_auth(auth_state_id:, name: OMIT, request_options: nil)
      @client.browser.modify_auth(
        @instance_id, 
        auth_state_id: auth_state_id, 
        name: name, 
        request_options: request_options
      )
    end
    
    def authenticate(auth_state_id:, request_options: nil)
      @client.browser.authenticate(
        @instance_id,
        auth_state_id: auth_state_id,
        request_options: request_options
      )
    end
    
    def act(actions, request_options: nil)
      @client.browser.act(@instance_id, actions: actions, request_options: request_options)
    end
  end

  # Legacy helper class
  class BrowserHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def act(actions, request_options: nil)
      @client.browser.act(@instance_id, actions: actions, request_options: request_options)
    end
  end

  # Code helper class
  class CodeHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def execute(code, kernel_name: OMIT, timeout: OMIT, request_options: nil)
      @client.code.execute(
        @instance_id, 
        code: code, 
        kernel_name: kernel_name, 
        timeout: timeout, 
        request_options: request_options
      )
    end
  end

  # Async Code helper class
  class AsyncCodeHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def execute(code, kernel_name: OMIT, timeout: OMIT, request_options: nil)
      @client.code.execute(
        @instance_id, 
        code: code, 
        kernel_name: kernel_name, 
        timeout: timeout, 
        request_options: request_options
      )
    end
  end

  # Notebook helper class
  class NotebookHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def list(request_options: nil)
      @client.notebook.list(@instance_id, request_options: request_options)
    end

    def get(notebook_id, request_options: nil)
      @client.notebook.get(@instance_id, notebook_id: notebook_id, request_options: request_options)
    end

    def create(name, kernel_name: OMIT, metadata: OMIT, request_options: nil)
      @client.notebook.create(
        @instance_id, 
        name: name, 
        kernel_name: kernel_name, 
        metadata: metadata, 
        request_options: request_options
      )
    end

    def delete(notebook_id, request_options: nil)
      @client.notebook.delete(@instance_id, notebook_id: notebook_id, request_options: request_options)
    end

    def add_cell(notebook_id, content, cell_type: OMIT, request_options: nil)
      @client.notebook.add_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        content: content, 
        cell_type: cell_type, 
        request_options: request_options
      )
    end

    def update_cell(notebook_id, cell_id, content: OMIT, cell_type: OMIT, request_options: nil)
      @client.notebook.update_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        content: content, 
        cell_type: cell_type, 
        request_options: request_options
      )
    end

    def delete_cell(notebook_id, cell_id, request_options: nil)
      @client.notebook.delete_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        request_options: request_options
      )
    end

    def execute_cell(notebook_id, cell_id, request_options: nil)
      @client.notebook.execute_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        request_options: request_options
      )
    end
  end

  # Async Notebook helper class
  class AsyncNotebookHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def list(request_options: nil)
      @client.notebook.list(@instance_id, request_options: request_options)
    end

    def get(notebook_id, request_options: nil)
      @client.notebook.get(@instance_id, notebook_id: notebook_id, request_options: request_options)
    end

    def create(name, kernel_name: OMIT, metadata: OMIT, request_options: nil)
      @client.notebook.create(
        @instance_id, 
        name: name, 
        kernel_name: kernel_name, 
        metadata: metadata, 
        request_options: request_options
      )
    end

    def delete(notebook_id, request_options: nil)
      @client.notebook.delete(@instance_id, notebook_id: notebook_id, request_options: request_options)
    end

    def add_cell(notebook_id, content, cell_type: OMIT, request_options: nil)
      @client.notebook.add_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        content: content, 
        cell_type: cell_type, 
        request_options: request_options
      )
    end

    def update_cell(notebook_id, cell_id, content: OMIT, cell_type: OMIT, request_options: nil)
      @client.notebook.update_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        content: content, 
        cell_type: cell_type, 
        request_options: request_options
      )
    end

    def delete_cell(notebook_id, cell_id, request_options: nil)
      @client.notebook.delete_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        request_options: request_options
      )
    end

    def execute_cell(notebook_id, cell_id, request_options: nil)
      @client.notebook.execute_cell(
        @instance_id, 
        notebook_id: notebook_id, 
        cell_id: cell_id, 
        request_options: request_options
      )
    end
  end

  # Env helper class
  class EnvHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def set(variables, request_options: nil)
      @client.env.set(@instance_id, variables: variables, request_options: request_options)
    end

    def get(request_options: nil)
      @client.env.get(@instance_id, request_options: request_options)
    end

    def delete(keys, request_options: nil)
      @client.env.delete(@instance_id, keys: keys, request_options: request_options)
    end
  end

  # Async Env helper class
  class AsyncEnvHelper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end

    def set(variables, request_options: nil)
      @client.env.set(@instance_id, variables: variables, request_options: request_options)
    end

    def get(request_options: nil)
      @client.env.get(@instance_id, request_options: request_options)
    end

    def delete(keys, request_options: nil)
      @client.env.delete(@instance_id, keys: keys, request_options: request_options)
    end
  end

  # Helper class for async browser operations
  class AsyncBrowserHelperWrapper
    def initialize(instance_id, client)
      @instance_id = instance_id
      @client = client
    end
    
    def start(request_options: nil)
      @client.browser.start(@instance_id, request_options: request_options)
    end
    
    def stop(request_options: nil)
      @client.browser.stop(@instance_id, request_options: request_options)
    end
    
    def get_cdp_url(request_options: nil)
      @client.browser.get_cdp_url(@instance_id, request_options: request_options)
    end
    
    def get_current_url(request_options: nil)
      @client.browser.get_current_url(@instance_id, request_options: request_options)
    end
    
    def save_auth(name: OMIT, request_options: nil)
      @client.browser.save_auth(@instance_id, name: name, request_options: request_options)
    end
    
    def modify_auth(auth_state_id:, name: OMIT, request_options: nil)
      @client.browser.modify_auth(
        @instance_id, 
        auth_state_id: auth_state_id, 
        name: name, 
        request_options: request_options
      )
    end
    
    def authenticate(auth_state_id:, request_options: nil)
      @client.browser.authenticate(
        @instance_id,
        auth_state_id: auth_state_id,
        request_options: request_options
      )
    end
    
    def act(actions:, request_options: nil)
      @client.browser.act(
        @instance_id,
        actions: actions,
        request_options: request_options
      )
    end
  end
end 