# frozen_string_literal: true

module MOSAIK
  module Collectors
    class History < Collector
      def call
        # Open the git repository
        git = Git.open(MOSAIK.options.directory, log: ::Logger.new(File::NULL))

        # Fetch commits since a specific date or last 1000 commits
        commits = options[:since] ? git.log.since(options[:since]) : git.log(1000)

        # Create a 2D matrix for each pair of nodes in the graph
        matrix = graph.nodes.map { |_| graph.nodes.map { |_| 0 } }

        # Calculate the aggregated local coupling
        commits.each do |commit|
          # Get the files for the commit
          constants = commit.diff_parent.stats[:files].map do |file|
            # Resolve file path to class name
            resolver.resolve(file)
          end

          # Calculate the local coupling
          constants
            .permutation(2)
            .each { |a, b| matrix[graph.nodes.index(a)][graph.nodes.index(b)] += 1 }
        end

        # For each non-zero element in the matrix, add an edge to the graph
        matrix.each_with_index do |row, i|
          row.each_with_index do |value, j|
            next if value.zero?

            # Add an edge from the node to the receiver
            graph.add_edge(graph.nodes[i], graph.nodes[j], label: value)
          end
        end
      end
    end
  end
end
