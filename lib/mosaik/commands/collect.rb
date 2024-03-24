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

        # Print the hierarchy recursively
        print_hierarchy(registry.hierarchy.constants)
      end

      private

      def print_hierarchy(hierarchy, level = 0)
        hierarchy.each do |constant, children|
          debug ("  " * level) + constant

          print_hierarchy(children, level + 1)
        end
      end
    end
  end
end
