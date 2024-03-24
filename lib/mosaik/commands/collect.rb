# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        parsers = {
          ".rb" => Parsers::Ruby.new,
        }

        registry = Registry.new

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          debug "Parsing file: #{file}"

          parsers
            .fetch(File.extname(file))
            .parse(file, registry)
        rescue KeyError
          raise UnknownFileType, "No parser for file type: #{File.extname(file)}"
        end

        # Print the registry
        registry.constants.each_value do |constant|
          info constant
        end
      end
    end
  end
end
