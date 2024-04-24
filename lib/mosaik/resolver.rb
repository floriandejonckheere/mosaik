# frozen_string_literal: true

module MOSAIK
  ##
  # Inference engine for resolving file paths to constant names, and vice versa
  #
  class Resolver
    attr_reader :directory, :load_paths, :overrides, :collapsed

    def initialize(directory, load_paths, overrides = {}, collapsed = [])
      @directory = directory
      @load_paths = load_paths
      @overrides = overrides
      @collapsed = collapsed
    end

    def override(**overrides)
      @overrides.merge!(overrides)
    end

    def collapse(*collapsed)
      @collapsed += collapsed
    end

    def resolve_file(abspath)
      # Get the file name without the extension
      file = File.basename(abspath, ".rb")

      # Get the path without the file name
      path = File.dirname(abspath)

      # Remove the collapsed directories
      collapsed.each do |dir|
        path = path.gsub(%r(#{dir}/?), dir.split("/")[..-2].join("/"))
      end

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

      # Generate potential paths
      paths = load_paths.flat_map do |load_path|
        # Regular file path
        abspath = File.join(directory, load_path, "#{file}.rb")

        # Directory path
        dirpath = File.join(directory, load_path, file)

        # Expanded file path
        expaths = collapsed.map do |dir|
          abspath.gsub(dir.split("/")[..-2].join("/"), dir)
        end

        [abspath, dirpath, *expaths]
      end

      # Check if the file or directory exists
      paths.uniq.find { |path| File.file?(path) || File.directory?(path) }
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
      overrides.key(string) || string
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z])(\d)/, '\1_\2')
        .gsub(/(\d)([A-Z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr("-", "_")
        .downcase
    end
  end
end
