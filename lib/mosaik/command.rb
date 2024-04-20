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
               hide_labels: false

      argument "--file FILE", "File for the identified microservice candidates graph (default: #{defaults[:file]})"

      argument "--visualize", "Enable graph visualization (default: #{defaults[:visualize]})"
      argument "--renderer RENDERER", "Graph renderer: dot, fdp, sfdp, or neato (default: #{defaults[:renderer]})"

      argument("--hide-uncoupled", "Hide uncoupled vertices in the graph (default: #{defaults[:hide_uncoupled]})") { |arg| !arg.nil? }
      argument("--hide-labels", "Hide labels in the graph (default: #{defaults[:hide_labels]})") { |arg| !arg.nil? }

      def validate
        raise OptionError, "unknown renderer: #{options[:renderer]}" unless options[:renderer].in? ["dot", "fdp", "sfdp", "neato"]
      end

      protected

      def visualize
        # Write graph to file
        File.write(options[:file], graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

        return unless options[:visualize]

        file = File.basename(options[:file], ".*")

        # Write visualization to file
        debug graph.to_dot(options)
        graph.to_svg(file, options)

        info "Dependency graph written to #{file}.gv and rendered to #{file}.svg"
      end
    end
  end
end
