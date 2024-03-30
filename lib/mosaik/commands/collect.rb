# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      defaults type: "static"

      argument "-t", "--type TYPE", "Type of collection (default: static, available: static, history)"
      argument "-f", "--force", "Overwrite existing file"

      # History options
      argument "--since DATE", "Include only commits from a specific date"

      def prepare
        raise OptionError, "unknown collection type: #{options[:type]}" unless options[:type].in? ["static", "history"]
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

        # Collect data and add to graph
        collector
          .new(options, graph)
          .call
      end

      private

      def collector
        case options[:type]
        when "static"
          Collectors::Static
        when "history"
          Collectors::History
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
