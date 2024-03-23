# frozen_string_literal: true

module MOSAIK
  class Configuration
    attr_reader :include, :exclude

    def initialize(include = [], exclude = [])
      @include = include
      @exclude = exclude
    end

    def self.from(file)
      raise ConfigurationError, "Configuration file not found: #{file}" unless File.exist?(file)

      configuration = YAML.load_file(file)

      new(
        configuration["include"],
        configuration["exclude"],
      )
    end
  end
end
