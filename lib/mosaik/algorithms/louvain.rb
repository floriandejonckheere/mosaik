# frozen_string_literal: true

module MOSAIK
  module Algorithms
    ##
    # Louvain method for community detection (Blondel et al., 2008)
    #
    class Louvain < Algorithm
      attr_reader :communities, :threshold

      def initialize(...)
        super

        # Initial set of communities
        @communities = graph
          .vertices
          .values
          .to_h { |vertex| [vertex.id, vertex] }

        # Threshold of modularity improvement
        @threshold = 1e-6
      end

      def call
        info "Total modularity: #{modularity}"

        i = 0

        # Iterate until no further improvement in modularity
        loop do
          debug "Iteration #{i += 1}: modularity=#{modularity}"

          initial_modularity = modularity

          # Phase 1: reassign vertices to optimize modularity
          graph.vertices.each_value do |vertex|
            reassign_vertex(vertex)
          end

          # Phase 2: reduce communities to a single node
          # TODO: Implement this phase

          break if modularity - initial_modularity <= threshold
        end

        # Print the community assignments
        communities.each do |vertex_id, community|
          debug "#{vertex_id} -> #{community.id}"
        end

        # Return the community assignments
        communities
          .transform_keys { |vertex_id| graph.find_vertex(vertex_id) }
          .transform_values(&:id)
      end

      private

      def reassign_vertex(vertex)
        # Initialize best community as current community
        best_community = communities[vertex.id]

        # Initialize best modularity gain
        best_gain = 0.0

        # Initialize best modularity
        best_modularity = modularity

        # Store the original community of the vertex
        community = communities[vertex.id]

        # Iterate over all neighbours of the vertex
        vertex.edges.each_key do |neighbour|
          # Skip if the neighbour is in the same community
          next if communities[vertex.id] == communities[neighbour]

          # Move the vertex to the neighbour's community
          communities[vertex.id] = communities[neighbour]

          # Calculate the new modularity
          new_modularity = modularity

          # Calculate the modularity gain
          gain = new_modularity - best_modularity

          # Update the best modularity gain and community
          if gain > best_gain
            best_gain = gain
            best_community = communities[neighbour]
          end

          # Move the vertex back to its original community
          communities[vertex.id] = community
        end

        # Move the vertex to the best community
        communities[vertex.id] = best_community
      end

      def modularity
        # Total weight of edges in the graph
        m = graph.total_weight

        # Modularity value
        q = 0.0

        # Iterate over each community
        communities.values.to_set.each do |community|
          # Find all vertices in the community
          vertices_in_community = communities.filter_map { |_, v| v if v == community }

          # Total weight of edges in the community
          c_weight_total = vertices_in_community
            .flat_map { |v| v.edges.values }
            .uniq
            .sum { |e| e.attributes.fetch(:weight, 0.0) }

          # Total weight of edges internal to the community
          c_weight_internal = 0.0

          # Iterate over all pairs of vertices in the community (calculate internal weight)
          vertices_in_community.combination(2) do |v, w|
            # Get weight of the edge between v and w
            weight = graph
              .find_vertex(v.id)
              .edges[w]
              &.attributes
              &.fetch(:weight, 0.0)

            c_weight_internal += weight
          end

          # Calculate modularity contribution from this community
          q += (c_weight_internal / m) - ((c_weight_total / (2 * m))**2)
        end

        # Return the total modularity
        q
      end
    end
  end
end
