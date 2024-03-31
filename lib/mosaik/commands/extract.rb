# frozen_string_literal: true

module MOSAIK
  module Commands
    class Extract < Command
      self.description = "Extract information"

      defaults type: "static"

      argument "-t", "--type TYPE", "Type of extraction (default: static, available: static, evolution)"

      # History options
      argument "--since DATE", "Include only commits from a specific date"

      def prepare
        raise OptionError, "unknown extraction type: #{options[:type]}" unless options[:type].in? ["static", "evolution"]
      end

      def start
        # Construct graph of classes based on file path
        graph = Graph::Graph.new

        MOSAIK.configuration.files.each do |file|
          # Resolve file path to class name
          class_name = resolver.resolve(file)

          # Add class to graph
          graph.find_or_add_vertex(class_name)
        end

        # Extract data and add to graph
        extractor
          .new(options, graph)
          .call
      end

      private

      def extractor
        case options[:type]
        when "static"
          Extractors::Static
        when "evolution"
          Extractors::Evolution
        end
      end

      def resolver
        @resolver ||= Resolver.new(
          MOSAIK.options.directory,
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
        )
      end
    end
  end
end
