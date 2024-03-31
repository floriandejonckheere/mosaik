# frozen_string_literal: true

module MOSAIK
  module Commands
    class Extract < Command
      self.description = "Extract information"

      defaults structural: 1,
               logical: 1,
               contributor: 1,
               since: nil,
               limit: 100

      argument "--structural N", Integer, "Weight of structural coupling extraction (default: 1)"
      argument "--logical N", Integer, "Weight of logical coupling extraction (default: 1)"
      argument "--contributor N", Integer, "Weight of coupling extraction (default: 1)"

      # Evolution options
      argument "--since DATE", "Include only commits from a specific date"
      argument "--limit N", Integer, "Limit the number of commits to analyze (default: 100)"

      def prepare
        raise OptionError, "negative value: #{options[:limit]}" if options[:limit].negative?
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
        when "structural"
          Extractors::Structural
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
