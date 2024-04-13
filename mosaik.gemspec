# frozen_string_literal: true

require_relative "lib/mosaik/version"

Gem::Specification.new do |spec|
  spec.name          = "mosaik"
  spec.version       = MOSAIK::VERSION
  spec.authors       = ["Florian Dejonckheere"]
  spec.email         = ["florian@floriandejonckheere.be"]

  spec.summary       = "Modular Optimization to Service-oriented Architecture Implementation Kit"
  spec.description   = "Toolkit for converting monolithic applications into modular, service-oriented architectures."
  spec.homepage      = "https://github.com/floriandejonckheere/mosaik"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new("~> 3.3")

  spec.metadata["source_code_uri"] = "https://github.com/floriandejonckheere/mosaik.git"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files         = Dir["README.md", "LICENSE.md", "CHANGELOG.md", "Gemfile", "bin/mosaik", "lib/**/*.rb", "config/*.rb"]
  spec.bindir        = "bin"
  spec.executables   = ["mosaik"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 7.1"
  spec.add_runtime_dependency "colorize", "~> 1.1"
  spec.add_runtime_dependency "csv", "~> 3.3"
  spec.add_runtime_dependency "git", "~> 1.19.1"
  spec.add_runtime_dependency "parser", "~> 3.3.0.5"
  spec.add_runtime_dependency "zeitwerk", "~> 2.6"
end
