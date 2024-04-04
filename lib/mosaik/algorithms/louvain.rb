# frozen_string_literal: true

module MOSAIK
  module Algorithms
    class Louvain < Algorithm
      attr_reader :communities

      def initialize(...)
        super

        # Initial set of communities
        @communities = graph
          .vertices
          .values
          .to_h { |vertex| [vertex.id, vertex] }
      end

      def call
        info "Total modularity: #{modularity}"
      end

      private

      def modularity
        # Total weight of edges in the graph
        m = graph.total_weight

        # Modularity value
        q = 0.0

        # Iterate over each community
        communities.values.to_set.each do |community|
          debug "Calculating modularity for community #{community.inspect}"

          # Find all vertices in the community
          vertices_in_community = communities.filter_map { |_, v| v if v == community }

          # Total weight of edges in the community
          c_weight_total = vertices_in_community
            .flat_map { |v| v.edges.values }
            .uniq
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          debug "Total weight of edges in the community: #{c_weight_total}"

          # Total weight of edges internal to the community
          c_weight_internal = 0.0

          # Iterate over all pairs of vertices in the community (calculate internal weight)
          vertices_in_community.combination(2) do |v, w|
            # Get weight of the edge between v and w
            weight = graph
              .find_vertex(v)
              .edges[w]
              &.attributes
              &.fetch(:weight, 0.0)

            c_weight_internal += weight
          end

          debug "Total weight of internal edges in the community: #{c_weight_internal}"

          # Calculate modularity contribution from this community
          q += (c_weight_internal / m) - ((c_weight_total / (2 * m))**2)
        end

        # Return the total modularity
        q
      end
    end
  end
end
