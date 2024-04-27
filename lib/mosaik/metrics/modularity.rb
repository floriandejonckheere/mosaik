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

        if m.zero?
          warn "Graph has no edges, modularity is zero"

          # Store modularity value in the graph
          graph.attributes[:modularity] = 0.0

          return 0.0
        end

        # Total modularity
        q = 0.0

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices
          vertices_in_cluster_id = vertices_in_cluster.map(&:id)

          # Skip if the cluster is empty
          (cluster.attributes[:modularity] = 0.0) and next if vertices_in_cluster.empty?

          # Edges outgoing from the cluster
          e_outgoing = vertices_in_cluster
            .map { |v| v.edges.values }
            .flatten(2)
            .uniq

          # Edges incoming to the cluster
          e_incoming = graph
            .vertices
            .each_value
            .map { |v| v.edges.slice(*vertices_in_cluster_id).values }
            .flatten(2)
            .uniq

          # Skip if there are no edges
          (cluster.attributes[:modularity] = 0.0) and next if vertices_in_cluster.empty?

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
              .find_edges(v.id, w.id)
              .sum { |e| e.attributes.fetch(:weight, 0.0) }

            c_weight_internal += weight
          end

          # Calculate modularity value for the cluster
          q_c = (c_weight_internal / (2 * m)) - ((c_weight_total / (2 * m))**2)

          # Store modularity value in the cluster
          cluster.attributes[:modularity] = q_c

          # Calculate modularity contribution from this cluster
          q += q_c
        end

        # Store modularity value in the graph
        graph.attributes[:modularity] = q

        # Return the total modularity
        q
      end
    end
  end
end
