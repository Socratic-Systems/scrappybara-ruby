# frozen_string_literal: true

module Scrappybara
  # Tools for controlling the browser
  module Tools
    # A tool for controlling the browser like a human using a computer
    class ComputerTool
      # Initialize a new ComputerTool
      #
      # @param client [Scrappybara::Client] The Scrappybara client
      def initialize(client)
        @client = client
      end

      # Execute a computer action
      #
      # @param action [String] The action to execute
      # @param args [Hash] Arguments for the action
      #
      # @return [Hash] Response from the action
      def act(action, **args)
        @client.instance.act(action: action, args: args)
      end

      # Navigate to a URL
      #
      # @param url [String] The URL to navigate to
      # @param wait_until [String] When to consider navigation complete
      #
      # @return [Hash] Response from the action
      def goto(url, wait_until: "load")
        act("goto", url: url, wait_until: wait_until)
      end

      # Click on an element
      #
      # @param selector [String] The selector to click
      # @param button [String] The button to click with
      # @param click_count [Integer] Number of clicks
      # @param delay [Integer] Delay between clicks in milliseconds
      # @param position_x [Float] X coordinate to click at
      # @param position_y [Float] Y coordinate to click at
      # @param modifiers [Array] Keyboard modifiers to hold
      # @param force [Boolean] Whether to force the click
      # @param no_wait_after [Boolean] Whether to wait for browser to settle
      # @param timeout [Integer] How long to wait for the selector in milliseconds
      #
      # @return [Hash] Response from the action
      def click(selector, button: "left", click_count: 1, delay: 0,
                position_x: nil, position_y: nil, modifiers: nil,
                force: false, no_wait_after: false, timeout: 30000)
        act("click", 
            selector: selector, 
            button: button, 
            click_count: click_count, 
            delay: delay,
            position: position_x && position_y ? { x: position_x, y: position_y } : nil,
            modifiers: modifiers,
            force: force, 
            no_wait_after: no_wait_after, 
            timeout: timeout)
      end

      # Fill a form field
      #
      # @param selector [String] The selector to fill
      # @param value [String] The value to fill
      # @param no_wait_after [Boolean] Whether to wait for browser to settle
      # @param timeout [Integer] How long to wait for the selector in milliseconds
      # @param force [Boolean] Whether to force the fill
      #
      # @return [Hash] Response from the action
      def fill(selector, value, no_wait_after: false, timeout: 30000, force: false)
        act("fill", 
            selector: selector, 
            value: value, 
            no_wait_after: no_wait_after, 
            timeout: timeout,
            force: force)
      end

      # Press keys on the keyboard
      #
      # @param key [String] Key or key combination to press
      # @param delay [Integer] Delay between key presses in milliseconds
      # @param no_wait_after [Boolean] Whether to wait for browser to settle
      #
      # @return [Hash] Response from the action
      def press(key, delay: 0, no_wait_after: false)
        act("press", key: key, delay: delay, no_wait_after: no_wait_after)
      end

      # Take a screenshot
      #
      # @param full_page [Boolean] Whether to capture the full page
      # @param quality [Integer] JPEG quality (0-100)
      # @param type [String] Image format type (jpeg or png)
      # @param omit_background [Boolean] Whether to hide the background
      # @param timeout [Integer] How long to wait in milliseconds
      #
      # @return [Hash] Response from the action with the screenshot data
      def screenshot(full_page: false, quality: nil, type: nil, 
                     omit_background: false, timeout: 30000)
        act("screenshot", 
            full_page: full_page, 
            quality: quality, 
            type: type, 
            omit_background: omit_background, 
            timeout: timeout)
      end

      # Get the content of the page
      #
      # @return [Hash] Response with the page content
      def content
        act("content")
      end

      # Evaluate JavaScript code in the browser
      #
      # @param expression [String] JavaScript code to evaluate
      # @param arg [Object] Argument to pass to the function
      #
      # @return [Hash] Response with the result of the evaluation
      def evaluate(expression, arg: nil)
        act("evaluate", expression: expression, arg: arg)
      end
      
      # Move the mouse to specific coordinates
      #
      # @param coordinates [Array] The coordinates to move to [x, y]
      # @param hold_keys [Array] Keyboard keys to hold while moving
      #
      # @return [Hash] Response from the action
      def move_mouse(coordinates, hold_keys: nil)
        raise ArgumentError, "coordinates is required for move_mouse action" unless coordinates
        act("move_mouse", coordinates: coordinates, hold_keys: hold_keys)
      end
      
      # Click the mouse at the current or specified position
      #
      # @param button [String] Mouse button to click ("left", "right", "middle")
      # @param click_type [String] Type of click ("click", "double", "down", "up")
      # @param coordinates [Array] Optional coordinates to move before clicking [x, y]
      # @param num_clicks [Integer] Number of clicks
      # @param hold_keys [Array] Keyboard keys to hold while clicking
      #
      # @return [Hash] Response from the action
      def click_mouse(button, click_type: "click", coordinates: nil, num_clicks: 1, hold_keys: nil)
        raise ArgumentError, "button is required for click_mouse action" unless button
        act("click_mouse", 
            button: button, 
            click_type: click_type, 
            coordinates: coordinates, 
            num_clicks: num_clicks, 
            hold_keys: hold_keys)
      end
      
      # Drag the mouse along a path
      #
      # @param path [Array] Array of coordinate pairs representing the drag path
      # @param hold_keys [Array] Keyboard keys to hold while dragging
      #
      # @return [Hash] Response from the action
      def drag_mouse(path, hold_keys: nil)
        raise ArgumentError, "path is required for drag_mouse action" unless path
        act("drag_mouse", path: path, hold_keys: hold_keys)
      end
      
      # Scroll the page
      #
      # @param delta_x [Float] Horizontal scroll amount
      # @param delta_y [Float] Vertical scroll amount
      # @param coordinates [Array] Optional coordinates to scroll at [x, y]
      # @param hold_keys [Array] Keyboard keys to hold while scrolling
      #
      # @return [Hash] Response from the action
      def scroll(delta_x: 0, delta_y: 0, coordinates: nil, hold_keys: nil)
        act("scroll", 
            delta_x: delta_x, 
            delta_y: delta_y, 
            coordinates: coordinates, 
            hold_keys: hold_keys)
      end
      
      # Press specific keys
      #
      # @param keys [Array] Array of keys to press
      # @param duration [Float] Time to hold keys in seconds
      #
      # @return [Hash] Response from the action
      def press_key(keys, duration: nil)
        raise ArgumentError, "keys is required for press_key action" unless keys
        act("press_key", keys: keys, duration: duration)
      end
      
      # Type text
      #
      # @param text [String] Text to type
      # @param hold_keys [Array] Keyboard keys to hold while typing
      #
      # @return [Hash] Response from the action
      def type_text(text, hold_keys: nil)
        raise ArgumentError, "text is required for type_text action" unless text
        act("type_text", text: text, hold_keys: hold_keys)
      end
      
      # Wait for a specified duration
      #
      # @param duration [Float] Duration to wait in seconds
      #
      # @return [Hash] Response from the action
      def wait(duration)
        raise ArgumentError, "duration is required for wait action" unless duration
        act("wait", duration: duration)
      end
      
      # Take a screenshot of the current view
      #
      # @return [Hash] Response from the action with screenshot data
      def take_screenshot
        act("take_screenshot")
      end
      
      # Get the current cursor position
      #
      # @return [Hash] Response from the action with cursor position
      def get_cursor_position
        act("get_cursor_position")
      end
    end

    # A tool for file editing commands
    class EditTool
      # Initialize a new EditTool
      #
      # @param client [Scrappybara::Client] The Scrappybara client
      def initialize(client)
        @client = client
      end

      # Execute a file operation
      #
      # @param command [String] The file command to execute (create, view, replace, etc.)
      # @param path [String] Path to the file
      # @param file_text [String] File content for create command
      # @param view_range [Array] Line range for view command [start, end]
      # @param old_str [String] String to replace
      # @param new_str [String] Replacement string
      # @param insert_line [Integer] Line number for insert command
      # @param text [String] Text to insert
      #
      # @return [Hash] Response from the file operation
      def edit(command, path:, file_text: nil, view_range: nil, old_str: nil, new_str: nil, insert_line: nil, text: nil)
        params = {
          command: command,
          path: path
        }

        case command
        when "create"
          raise ArgumentError, "file_text is required for create command" unless file_text
          params[:content] = file_text
        when "view"
          params[:view_range] = view_range if view_range
        when "replace"
          raise ArgumentError, "old_str and new_str are required for replace command" unless old_str && new_str
          params[:old_str] = old_str
          params[:new_str] = new_str
        when "insert"
          raise ArgumentError, "insert_line and text are required for insert command" unless insert_line && text
          params[:line] = insert_line
          params[:text] = text
        end

        @client.instance.file(@client.id, **params)
      end

      # Create a new file
      #
      # @param path [String] Path to create the file
      # @param content [String] Content of the file
      #
      # @return [Hash] Response from the create operation
      def create(path, content)
        edit("create", path: path, file_text: content)
      end

      # View file contents
      #
      # @param path [String] Path to the file to view
      # @param view_range [Array] Optional line range to view [start, end]
      #
      # @return [Hash] Response with the file content
      def view(path, view_range: nil)
        edit("view", path: path, view_range: view_range)
      end

      # Replace text in a file
      #
      # @param path [String] Path to the file
      # @param old_str [String] String to replace
      # @param new_str [String] Replacement string
      #
      # @return [Hash] Response from the replace operation
      def replace(path, old_str, new_str)
        edit("replace", path: path, old_str: old_str, new_str: new_str)
      end

      # Insert text at a specific line
      #
      # @param path [String] Path to the file
      # @param line [Integer] Line number to insert at
      # @param text [String] Text to insert
      #
      # @return [Hash] Response from the insert operation
      def insert(path, line, text)
        edit("insert", path: path, insert_line: line, text: text)
      end

      # Append text to a file
      #
      # @param path [String] Path to the file
      # @param text [String] Text to append
      #
      # @return [Hash] Response from the append operation
      def append(path, text)
        edit("append", path: path, text: text)
      end

      # Delete a file
      #
      # @param path [String] Path to the file to delete
      #
      # @return [Hash] Response from the delete operation
      def delete(path)
        edit("delete", path: path)
      end
    end

    # A tool for executing bash commands
    class BashTool
      # Initialize a new BashTool
      #
      # @param client [Scrappybara::Client] The Scrappybara client
      def initialize(client)
        @client = client
      end

      # Execute a bash command
      #
      # @param command [String] The bash command to execute
      # @param wait [Boolean] Whether to wait for command completion
      # @param restart [Boolean] Whether to restart the shell session
      # @param get_background_processes [Boolean] Retrieve information about background processes
      # @param kill_pid [Integer] Process ID to kill
      #
      # @return [Hash] Response from the command execution
      def bash(command: nil, wait: nil, restart: nil, get_background_processes: nil, kill_pid: nil)
        params = {}
        params[:command] = command if command
        params[:wait] = wait if wait
        params[:restart] = restart if restart
        params[:get_background_processes] = get_background_processes if get_background_processes
        params[:kill_pid] = kill_pid if kill_pid
        
        @client.instance.bash(@client.id, **params)
      end

      # Execute a bash command and wait for completion
      #
      # @param command [String] The bash command to execute
      #
      # @return [Hash] Response from the command execution
      def execute(command)
        bash(command: command, wait: true)
      end

      # Execute a bash command in the background
      #
      # @param command [String] The bash command to execute
      #
      # @return [Hash] Response from the command execution
      def execute_background(command)
        bash(command: command, wait: false)
      end

      # Restart the shell session
      #
      # @return [Hash] Response from the restart operation
      def restart_shell
        bash(restart: true)
      end

      # Get a list of background processes
      #
      # @return [Hash] Response with background process information
      def get_background_processes
        bash(get_background_processes: true)
      end

      # Kill a process by its PID
      #
      # @param pid [Integer] The process ID to kill
      #
      # @return [Hash] Response from the kill operation
      def kill_process(pid)
        bash(kill_pid: pid)
      end
    end
  end
end 