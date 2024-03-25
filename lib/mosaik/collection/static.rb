# frozen_string_literal: true

module MOSAIK
  module Collection
    class Static
      PARSERS = {
        ".rb" => Parsers::Ruby,
      }.freeze

      def call
        # Instantiate a constant registry
        registry = Registry.new

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          PARSERS
            .fetch(File.extname(file))
            .new
            .parse(file, registry)
        rescue KeyError
          raise UnknownFileType, "No parser for file type: #{File.extname(file)}"
        end

        # Print the registry
        registry.each do |constant|
          debug constant

          constant.methods.each_value do |method|
            debug "  #{method}"

            method.references.each do |reference|
              debug "    #{reference}"
            end
          end

          # Print the hierarchy
          debug ("  " * constant.name.scan("::").count) + constant.name
        end
      end
    end
  end
end
