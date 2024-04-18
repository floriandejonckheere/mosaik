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
               hide_uncoupled: false,
               hide_labels: false

      argument "--file FILE", "File for the identified microservice candidates graph (default: #{defaults[:file]})"

      argument("--hide-uncoupled", "Hide uncoupled vertices in the graph (default: #{defaults[:hide_uncoupled]})") { |arg| !arg.nil? }
      argument("--hide-labels", "Hide labels in the graph (default: #{defaults[:hide_labels]})") { |arg| !arg.nil? }

      def validate
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
      end
    end
  end
end
