# frozen_string_literal: true

module MOSAIK
  ##
  # Configuration parser (mosaik.yml)
  #
  class Configuration
    attr_reader :load_paths, :includes, :excludes, :overrides

    def initialize(load_paths: [], includes: [], excludes: [], overrides: {})
      @load_paths = load_paths
      @includes = includes
      @excludes = excludes
      @overrides = overrides
    end

    def files
      @files ||= begin
        included_files = Dir[*load_paths.flat_map { |p| includes.map { |i| File.join(MOSAIK.options.directory, p, i) } }]
        excluded_files = Dir[*load_paths.flat_map { |p| excludes.map { |e| File.join(MOSAIK.options.directory, p, e) } }]

        included_files - excluded_files
      end
    end

    def self.from(file)
      raise ConfigurationError, "Configuration file not found: #{file}" unless File.exist?(file)

      configuration = YAML.load_file(file)

      new(
        load_paths: Array(configuration["load_paths"]),
        includes: Array(configuration["include"]),
        excludes: Array(configuration["exclude"]),
        overrides: configuration["overrides"] || {},
      )
    end
  end
end
