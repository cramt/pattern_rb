# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("./lib", __dir__)

require_relative "lib/pattern/version"

Gem::Specification.new do |spec|
  spec.name = "pattern"
  spec.version = Pattern::VERSION
  spec.authors = ["Alexandra Østermark"]
  spec.email = ["alex.cramt@gmail.com"]

  spec.summary = "a pattern matcher for ruby"
  spec.description = "a pattern matcher for ruby"
  spec.homepage = "https://www.google.com"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.google.com"
  spec.metadata["changelog_uri"] = "https://www.google.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
