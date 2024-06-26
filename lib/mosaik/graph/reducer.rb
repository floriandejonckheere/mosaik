# frozen_string_literal: true

# typed: true

module MOSAIK
  module Graph
    ##
    # Reduce the graph (aggregate common edges and normalize weights)
    #
    class Reducer
      attr_reader :options, :graph

      def initialize(options, graph)
        @options = options
        @graph = graph
      end

      def call(directed: false)
        # Iterate over all combinations of vertices
        weights = graph.vertices.keys.combination(2).filter_map do |v1, v2|
          # Find all edges between the two vertices
          edges = Set.new(graph.find_edges(v1, v2) + graph.find_edges(v2, v1))

          # Calculate the weight for the aggregate edge
          weight = 0.0

          # Add weight for structural coupling
          weight += options[:structural] * edges
            .select { |e| e.attributes[:type] == "structural" }
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Add weight for logical coupling
          weight += options[:logical] * edges
            .select { |e| e.attributes[:type] == "logical" }
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Add weight for contributor coupling
          weight += options[:contributor] * edges
            .select { |e| e.attributes[:type] == "contributor" }
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Don't add zero weights
          next if weight.zero?

          # Return vertices and weights
          [v1, v2, weight]
        end

        # Remove all existing edges
        graph.vertices.each_value { |v| v.edges.clear }

        # Set graph directionality
        graph.directed = directed

        # Add new edges
        weights.each { |v1, v2, weight| graph.add_edge(v1, v2, weight:) unless weight.zero? }
      end
    end
  end
end
