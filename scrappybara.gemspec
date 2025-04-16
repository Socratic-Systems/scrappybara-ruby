lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scrappybara/version"

Gem::Specification.new do |spec|
  spec.name = "scrappybara"
  spec.version = Scrappybara::VERSION
  spec.authors = ["ScrapyBara"]
  spec.email = ["info@scrappybara.com"]

  spec.summary = "Ruby client for the ScrapyBara API"
  spec.description = "A Ruby client for interacting with the ScrapyBara API to control remote environments"
  spec.homepage = "https://github.com/scrappybara/scrappybara-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
  }

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "json", "~> 2.0"
  spec.add_dependency "zeitwerk", "~> 2.4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
end 