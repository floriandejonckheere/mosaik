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
      defaults file: "mosaik.csv",
               visualize: false,
               renderer: "dot",
               hide_uncoupled: false,
               hide_labels: false,
               reduce: false

      argument "--file FILE", "File for the dependency graph (default: #{defaults[:file]})"

      argument "--visualize", "Enable graph visualization (default: #{defaults[:visualize]})"
      argument "--renderer RENDERER", "Graph renderer: dot, fdp, sfdp, or neato (default: #{defaults[:renderer]})"

      argument("--hide-uncoupled", "Hide uncoupled vertices in the graph (default: #{defaults[:hide_uncoupled]})") { |arg| !arg.nil? }
      argument("--hide-labels", "Hide labels in the graph (default: #{defaults[:hide_labels]})") { |arg| !arg.nil? }

      argument "--reduce", "Reduce the graph before visualization (default: #{defaults[:reduce]})"

      def validate
        raise OptionError, "unknown renderer: #{options[:renderer]}" unless options[:renderer].in? ["dot", "fdp", "sfdp", "neato"]
      end

      protected

      def visualize
        # Write graph to file
        File.write(options[:file], graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

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

        file = File.basename(options[:file], ".*")

        # Write visualization to file
        debug visualizer.to_dot
        visualizer.to_svg(file)

        info "Dependency graph written to #{file}.gv and rendered to #{file}.svg"
      end
    end
  end
end
