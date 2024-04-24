# frozen_string_literal: true

module MOSAIK
  module Algorithms
    ##
    # Louvain method for community detection (Blondel et al., 2008)
    #
    class Louvain < Algorithm
      # Threshold of modularity improvement
      EPSILON = 1e-6

      def call
        # Assign initial set of communities (each vertex in its own community)
        graph.vertices.each_value.with_index do |vertex, i|
          graph
            .add_cluster("C#{i}")
            .add_vertex(vertex)
        end

        # Calculate initial modularity
        modularity = modularity_for(graph)

        info "Initial modularity: #{modularity}"

        # Iterate until no further improvement in modularity
        1.step do |i|
          debug "Iteration #{i}: initial modularity = #{modularity}"

          # Phase 1: reassign vertices to optimize modularity
          graph.vertices.each_value do |vertex|
            reassign_vertex(vertex)
          end

          # Phase 2: reduce communities to a single node
          # TODO: Implement this phase

          # Calculate final modularity
          final_modularity = modularity_for(graph)

          # Stop iterating if no further improvement in modularity
          break if final_modularity - modularity <= EPSILON

          # Update modularity
          modularity = final_modularity
        end

        info "Final modularity: #{modularity}"
      end

      private

      def reassign_vertex(vertex)
        # Initialize best community as current community
        best_community = graph.clusters.values.find { |cluster| cluster.vertices.include? vertex }

        # Initialize best modularity gain
        best_gain = 0.0

        # Initialize best modularity
        best_modularity = modularity_for(graph)

        # Store the original community of the vertex
        community = graph.clusters.values.find { |cluster| cluster.vertices.include? vertex }

        # Iterate over all neighbours of the vertex
        vertex.edges.each_key do |neighbour_id|
          neighbour = graph.find_vertex(neighbour_id)
          neighbour_community = graph.clusters.values.find { |cluster| cluster.vertices.include? neighbour }

          # Skip if the neighbour is in the same community
          next if neighbour_community == community

          # Move the vertex to the neighbour's community
          community.remove_vertex(vertex)
          neighbour_community.add_vertex(vertex)

          # Calculate the new modularity
          new_modularity = modularity_for(graph)

          # Calculate the modularity gain
          gain = new_modularity - best_modularity

          # Update the best modularity gain and community
          if gain > best_gain
            best_gain = gain
            best_community = neighbour_community
          end

          # Move the vertex back to its original community
          neighbour_community.remove_vertex(vertex)
          community.add_vertex(vertex)
        end

        # Move the vertex to the best community
        community.remove_vertex(vertex)
        best_community.add_vertex(vertex)

        # Return the best modularity
        best_modularity
      end

      def modularity_for(graph)
        Metrics::Modularity
          .new(options, graph)
          .evaluate
      end
    end
  end
end
