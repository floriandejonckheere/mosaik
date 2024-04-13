# frozen_string_literal: true

module MOSAIK
  module Metrics
    ##
    # Modularity (M. E. J. Newman and M. Girvan, 2003)
    #
    class Modularity < Metric
      def evaluate
        # Total weight of edges in the graph
        m = graph.total_weight

        # Modularity value
        q = 0.0

        # Iterate over each community
        graph.clusters.each_value do |cluster|
          # Find all vertices in the community
          vertices_in_community = cluster.vertices

          # Total weight of edges in the community
          c_weight_total = vertices_in_community
            .flat_map { |v| v.edges.values }
            .uniq
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Total weight of edges internal to the community
          c_weight_internal = 0.0

          # Iterate over all pairs of vertices in the community (calculate internal weight)
          vertices_in_community.to_a.combination(2) do |v, w|
            # Get weight of the edge between v and w
            weight = graph
              .find_edge(v.id, w.id)
              &.attributes
              &.[](:weight) || 0.0

            c_weight_internal += weight
          end

          # Calculate modularity contribution from this community
          q += (c_weight_internal / (2 * m)) - ((c_weight_total / (2 * m))**2)
        end

        # Return the total modularity
        q
      end
    end
  end
end
