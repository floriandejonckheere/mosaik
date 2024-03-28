# frozen_string_literal: true

module MOSAIK
  ##
  # Inference engine for resolving file paths to constant names
  #
  class Resolver
    attr_reader :directory, :load_paths, :overrides

    def initialize(directory, load_paths, overrides = {})
      @directory = directory
      @load_paths = load_paths
      @overrides = overrides
    end

    def override(**overrides)
      @overrides.merge!(overrides)
    end

    def resolve(abspath)
      # Get the file name without the extension
      file = File.basename(abspath, ".rb")

      # Get the path without the file name
      path = File.dirname(abspath)

      # Return unless the path is in the load paths
      return unless load_paths.any? { |load_path| path.start_with?(load_path) }

      # Remove the load path prefix (e.g. lib/)
      load_paths.each do |load_path|
        path = path.gsub(%r(#{load_path}/?), "")
      end

      # Convert the path and file name to a constant name
      path
        .split("/")
        .map { |p| camelize(p) }
        .append(camelize(file))
        .join("::")
    end

    private

    def camelize(string)
      overrides[string] || string.split("_").map(&:capitalize).join
    end
  end
end
