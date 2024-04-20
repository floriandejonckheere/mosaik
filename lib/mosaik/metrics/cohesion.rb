# frozen_string_literal: true

module MOSAIK
  module Metrics
    ##
    # Cohesion (S. Chidamber and C. Kemerer, 1994)
    #
    class Cohesion < Metric
      def evaluate
        # Total cohesion
        cohesion = 0.0

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices
          vertices_in_cluster_id = vertices_in_cluster.map(&:id)

          # Calculate the cardinality of the cluster
          cardinality_c = vertices_in_cluster.sum do |v|
            warn "No `methods` attribute found for #{v.id}" if v.attributes[:methods].nil?

            v.attributes[:methods] || 0.0
          end

          # Skip if the vertex has less than 2 methods (denominator would be 0)
          if cardinality_c < 2
            debug "Cluster #{cluster.id} has less than 2 methods, skipping cohesion calculation"

            # Store cohesion value in the cluster
            cluster.attributes[:cohesion] = 0.0

            next
          end

          # Calculate sum of edges between vertices in the cluster
          sum = vertices_in_cluster
            .map { |v| v.edges.slice(*vertices_in_cluster_id).values }
            .flatten(2)
            .uniq
            .count

          # Calculate cohesion value for the cluster
          cohesion_c = sum.to_f / (cardinality_c * (cardinality_c - 1) / 2)

          # Store cohesion value in the cluster
          cluster.attributes[:cohesion] = cohesion_c

          # Calculate cohesion contribution from this cluster
          cohesion += cohesion_c
        end

        # Store cohesion value in the graph
        graph.attributes[:cohesion] = cohesion

        # Return the total cohesion
        cohesion
      end
    end
  end
end
