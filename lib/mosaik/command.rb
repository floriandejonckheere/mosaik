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
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
        raise OptionError, "unknown renderer: #{options[:renderer]}" unless options[:renderer].in? ["dot", "fdp", "sfdp", "neato"]
      end
    end
  end
end
