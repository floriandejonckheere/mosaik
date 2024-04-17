# frozen_string_literal: true

module MOSAIK
  module Metrics
    ##
    # Coupling (S. Chidamber and C. Kemerer, 1994)
    #
    class Coupling < Metric
      def evaluate
        # Total coupling
        coupling = 0.0

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices
          vertices_in_cluster_id = vertices_in_cluster.map(&:id)

          # Calculate coupling value for the cluster
          coupling_c = 0.0

          # Iterate over all vertices in the cluster
          vertices_in_cluster.each do |v|
            v.edges.each do |i, es|
              next if i.in? vertices_in_cluster_id

              coupling_c += es.sum { |e| e.attributes.fetch(:weight, 0.0) }
            end
          end

          # Store coupling value in the cluster
          cluster.attributes[:coupling] = coupling_c

          # Calculate coupling contribution from this cluster
          coupling += coupling_c
        end

        # Store coupling value in the graph
        graph.attributes[:coupling] = coupling

        # Return the total coupling
        coupling
      end
    end
  end
end
