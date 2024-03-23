# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        parsers = {
          ".rb" => Parsers::Ruby.new,
        }

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          info "Parsing file: #{file}"

          parsers
            .fetch(File.extname(file))
            .parse(file)
        rescue KeyError
          raise UnknownFileType, "No parser for file type: #{File.extname(file)}"
        end
      end
    end
  end
end
