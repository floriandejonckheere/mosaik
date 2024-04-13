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

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices
          vertices_in_cluster_id = vertices_in_cluster.map(&:id)

          # Edges outgoing from the cluster
          e_outgoing = vertices_in_cluster
            .flat_map { |v| v.edges.values }

          # Edges incoming to the cluster
          e_incoming = graph
            .vertices
            .each_value
            .flat_map { |v| v.edges.to_a }
            .filter_map { |i, e| e if i.in? vertices_in_cluster_id }

          # Total weight of edges in the cluster
          c_weight_total = (e_outgoing + e_incoming)
            .to_set
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Total weight of edges internal to the cluster
          c_weight_internal = 0.0

          # Iterate over all pairs of vertices in the cluster (calculate internal weight)
          vertices_in_cluster.to_a.combination(2) do |v, w|
            # Get weight of the edge between v and w
            weight = graph
              .find_edge(v.id, w.id)
              &.attributes
              &.[](:weight) || 0.0

            c_weight_internal += weight
          end

          q_c = (c_weight_internal / (2 * m)) - ((c_weight_total / (2 * m))**2)

          # Calculate modularity contribution from this cluster
          q += q_c
        end

        # Return the total modularity
        q
      end
    end
  end
end
