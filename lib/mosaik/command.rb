# frozen_string_literal: true

module MOSAIK
  ##
  # Base class for commands
  #
  class Command
    include Arguments

    def validate; end

    def call; end

    ##
    # Base class for commands that output graphs
    class Graph < Command
      defaults input: "mosaik.csv",
               output: "mosaik.csv",
               visualize: false,
               renderer: "dot",
               show_uncoupled: false,
               show_labels: false,
               reduce: false

      argument "--input FILE", "Input file for the dependency graph (default: #{defaults[:input]})"
      argument "--output FILE", "Output file for the dependency graph (default: #{defaults[:output]})"

      argument "--visualize", "Enable graph visualization (default: #{defaults[:visualize]})"
      argument "--renderer RENDERER", "Graph renderer: dot, fdp, sfdp, or neato (default: #{defaults[:renderer]})"

      argument("--show-uncoupled", "Show uncoupled vertices in the graph (default: #{defaults[:show_uncoupled]})") { |arg| !arg.nil? }
      argument("--show-labels", "Show labels in the graph (default: #{defaults[:show_labels]})") { |arg| !arg.nil? }

      argument "--reduce", "Reduce the graph before visualization (default: #{defaults[:reduce]})"

      def validate
        raise OptionError, "unknown renderer: #{options[:renderer]}" unless options[:renderer].in? ["dot", "fdp", "sfdp", "neato"]
      end

      protected

      def write_graph
        # Write graph to file
        File.write(options[:output], graph.to_csv)

        info "Dependency graph written to #{options[:output]}"
      end

      def visualize_graph
        return unless options[:visualize]

        visualizer = MOSAIK::Graph::Visualizer
          .new(options, graph)

        if options[:reduce]
          # Override edge weights
          options[:structural] = 1
          options[:logical] = 1
          options[:contributor] = 1

          # Reduce the graph
          MOSAIK::Graph::Reducer
            .new(options, graph)
            .call(directed: true)
        end

        file = File.basename(options[:output], ".*")

        # Write visualization to file
        debug visualizer.to_dot
        visualizer.to_svg(file)

        info "Dependency graph written to #{file}.gv and rendered to #{file}.svg"
      end
    end
  end
end
