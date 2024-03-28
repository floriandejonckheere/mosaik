# frozen_string_literal: true

module MOSAIK
  class Configuration
    attr_reader :directory, :paths, :includes, :excludes

    def initialize(directory:, paths: [], includes: [], excludes: [])
      @directory = directory
      @paths = paths
      @includes = includes
      @excludes = excludes
    end

    def files
      @files ||= begin
        included_files = Dir[*paths.flat_map { |p| includes.map { |i| File.join(directory, p, i) } }]
        excluded_files = Dir[*paths.flat_map { |p| excludes.map { |e| File.join(directory, p, e) } }]

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
