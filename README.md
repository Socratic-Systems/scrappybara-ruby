# Scrappybara Ruby Client

A Ruby client library for interacting with the Scrappybara API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scrappybara'
```

And then execute:

```
bundle install
```

Or install it yourself as:

```
gem install scrappybara
```

## Usage

### Basic initialization

```ruby
require 'scrappybara'

# Initialize the client with your API key
client = Scrappybara.new(api_key: "your-api-key")

# You can also use the SCRAPYBARA_API_KEY environment variable
# client = Scrappybara.new
```

### Starting instances

```ruby
# Start an Ubuntu instance
ubuntu_instance = client.start_ubuntu()

# Start a Chrome instance
chrome_instance = client.start_chrome()

# Start a Firefox instance
firefox_instance = client.start_firefox()

# Start a Jupyter instance
jupyter_instance = client.start_jupyter()
```

### Working with instances

```ruby
# Get instance info
instance_info = ubuntu_instance.get()

# Run a bash command
result = ubuntu_instance.bash("ls -la")
puts result.output

# Upload a file
ubuntu_instance.upload("/path/to/destination", "local_file.txt")

# Stop the instance
ubuntu_instance.stop()
```

### Working with browsers

```ruby
# Start a Chrome instance
chrome_instance = client.start_chrome()

# Start the browser
chrome_instance.start_browser()

# Perform browser actions
chrome_instance.act([
  { "type" => "goto", "url" => "https://example.com" },
  { "type" => "click", "selector" => "a.button" }
])

# Get the current URL
url = chrome_instance.get_current_url()
puts url

# Stop the browser
chrome_instance.stop_browser()

# Stop the instance
chrome_instance.stop()
```

### Working with code

```ruby
# Start a Jupyter instance
jupyter_instance = client.start_jupyter()

# Execute code
result = jupyter_instance.code.execute("print('Hello, World!')")
puts result
```

### Environment variables

```ruby
# Set environment variables
ubuntu_instance.env.set({
  "API_KEY" => "secret-key",
  "DEBUG" => "true"
})

# Get environment variables
env_vars = ubuntu_instance.env.get()
puts env_vars.variables

# Delete environment variables
ubuntu_instance.env.delete(["API_KEY"])
```

### Async operations

The library also provides an async client that returns Promise-like objects:

```ruby
require 'scrappybara'

# Initialize the async client
client = Scrappybara.async(api_key: "your-api-key")

# Start an instance
instance_promise = client.start_ubuntu()
instance = instance_promise.await

# Execute a bash command
result_promise = instance.bash("ls -la")
result = result_promise.await
puts result.output
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scrappybara/scrappybara-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 