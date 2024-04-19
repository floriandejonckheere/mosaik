# frozen_string_literal: true

module MOSAIK
  ##
  # Inference engine for resolving file paths to constant names, and vice versa
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

    def resolve_file(abspath)
      # Get the file name without the extension
      file = File.basename(abspath, ".rb")

      # Get the path without the file name
      path = File.dirname(abspath)

      # Remove the directory prefix
      path = path.gsub(%r(#{directory}/?), "")

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

    def resolve_constant(constant_name)
      # Convert the constant name to a file path
      file = constant_name
        .split("::")
        .map { |c| underscore(c) }
        .join("/")

      # Check if the file exists in any of the load paths
      load_paths.each do |load_path|
        abspath = File.join(directory, load_path, "#{file}.rb")

        return abspath if File.file?(abspath)
      end

      nil
    end

    def resolve_file!(abspath)
      resolve_file(abspath) || raise(ResolveError, "cannot resolve #{abspath} in: #{load_paths.join(', ')}")
    end

    def resolve_constant!(constant)
      resolve_constant(constant) || raise(ResolveError, "cannot resolve #{constant} in: #{load_paths.join(', ')}")
    end

    private

    def camelize(string)
      overrides[string] || string.split("_").map(&:capitalize).join
    end

    def underscore(string)
      string.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
  end
end
