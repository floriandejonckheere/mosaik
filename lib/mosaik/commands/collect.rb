# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      defaults type: "static",
               output: "mosaik.dot",
               force: false

      argument "-t", "--type TYPE", "Type of collection (default: static, available: static, history)"
      argument "-o", "--output OUTPUT", "Output file (default: mosaik.dot)"
      argument "-f", "--force", "Overwrite existing file"
      argument "-r", "--render", "Render a PNG image of the graph"

      # History options
      argument "--since DATE", "Include only commits from a specific date"

      def prepare
        raise OptionError, "unknown collection type: #{options[:type]}" unless options[:type].in? ["static", "history"]
        raise OptionError, "file already exists: #{options[:output]}, use --force to overwrite" if File.exist?(options[:output]) && !options[:force]
      end

      def start
        # Construct graph of classes based on file path
        graph = GraphViz.new(:class_graph, type: :digraph)

        MOSAIK.configuration.files.each do |file|
          # Resolve file path to class name
          class_name = resolver.resolve(file)

          # Add class to graph
          graph.add_node(class_name)
        end

        # Collect data and add to graph
        collector
          .new(options, graph)
          .call

        # Write the graph to a file
        graph.output(dot: options[:output])
        info "Graph written to #{options[:output]}"

        return unless options[:render]

        # Render the graph to a PNG image
        graph.output(png: "#{File.basename(options[:output], '.dot')}.png")
        info "Graph rendered to #{"#{File.basename(options[:output], '.dot')}.png"}"
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
