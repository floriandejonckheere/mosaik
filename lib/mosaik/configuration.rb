# frozen_string_literal: true

module MOSAIK
  class Configuration
    attr_reader :directory, :includes, :excludes

    def initialize(directory:, includes: [], excludes: [])
      @directory = directory
      @includes = includes
      @excludes = excludes
    end

    def files
      @files ||= begin
        included_files = Dir[*includes.map { |i| "#{directory}/#{i}" }]
        excluded_files = Dir[*excludes.map { |e| "#{directory}/#{e}" }]

        included_files - excluded_files
      end
    end

    def self.from(file)
      raise ConfigurationError, "Configuration file not found: #{file}" unless File.exist?(file)

      configuration = YAML.load_file(file)

      new(
        directory: File.dirname(file),
        includes: Array(configuration["include"]),
        excludes: Array(configuration["exclude"]),
      )
    end
  end
end
