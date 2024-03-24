# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        parsers = {
          ".rb" => Parsers::Ruby.new,
        }

        # Instantiate a constant registry
        registry = Registry.new

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          parsers
            .fetch(File.extname(file))
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
        end

        # Print the hierarchy
        registry.each do |constant|
          debug ("  " * constant.name.scan("::").count) + constant.name
        end
      end
    end
  end
end
