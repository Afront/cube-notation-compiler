# frozen_string_literal: true

require_relative "lib/cunoco/version"

Gem::Specification.new do |spec|
  spec.name          = "cunoco"
  spec.version       = Cunoco::VERSION
  spec.authors       = ["Afront"]
  spec.email         = ["3943720+Afront@users.noreply.github.com"]

  spec.summary       = "Simplifies the Singmaster Notation used in Rubik's cubes"
  spec.description   = "Compiles the Extended Singmaster Notation for the Rubik's cube into a simpler notation"
  spec.homepage      = "https://github.com/Afront/cube-notation-compiler"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

#  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Afront/cube-notation-compiler"
#  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
