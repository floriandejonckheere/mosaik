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
        # Store the original graph
        original_graph = graph

        # Initialize modularity
        modularity = nil

        # Final mapping of vertices to communities
        mapping = graph
          .vertices
          .keys
          .index_with { |vertex_id| vertex_id }

        # Iterate until no further improvement in modularity
        1.step do |i|
          # Assign initial set of communities (each vertex in its own community)
          graph.vertices.each_value do |vertex|
            graph
              .add_cluster(vertex.id)
              .add_vertex(vertex)
          end

          # Calculate and print initial modularity on first iteration
          if modularity.nil?
            modularity = modularity_for(graph)

            info "Initial modularity: #{modularity}"
          end

          debug "Iteration #{i}: start modularity=#{modularity}, vertices=#{graph.vertices.count}, communities=#{graph.clusters.count}"

          # Phase 1: reassign vertices to optimize modularity
          graph.vertices.each_value do |vertex|
            reassign_vertex(graph, vertex)
          end

          # Phase 2: reduce communities to a single node
          g, reduced_mapping = reduce_graph(graph)

          debug "Reduced #{graph.vertices.size} vertices to #{g.vertices.size} vertices"
          debug "Mapping: #{reduced_mapping.inspect}"
          debug "Changes: #{reduced_mapping.reject { |a, b| a == b }.inspect}"

          if options[:visualize]
            MOSAIK::Graph::Visualizer
              .new(options, g)
              .to_svg("louvain_#{i}")
          end

          # Merge the reduced mapping with the original mapping
          mapping = mapping.transform_values { |v| reduced_mapping[v] }

          # Calculate final modularity
          final_modularity = modularity_for(graph)

          debug "Iteration #{i}: end modularity=#{final_modularity}, vertices=#{graph.vertices.count}, communities=#{graph.clusters.count}"

          # Stop iterating if no further improvement in modularity
          break if final_modularity - modularity <= EPSILON

          # Update modularity
          modularity = final_modularity

          # Update the reduced graph
          @graph = g
        end

        info "Final modularity: #{modularity}"

        # Copy the final communities to the original graph
        original_graph.clusters.clear

        mapping.each do |vertex_id, community_id|
          original_graph
            .find_or_add_cluster(community_id)
            .add_vertex(original_graph.find_vertex(vertex_id))
        end
      end

      private

      def reassign_vertex(graph, vertex)
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
          # Find the community of the neighbour
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

      def reduce_graph(graph)
        raise NotImplementedError, "Directed graphs are not supported" if graph.directed

        # Create a new graph
        reduced_graph = Graph::Graph.new(directed: graph.directed)

        # Mapping of vertices to communities
        reduced_mapping = graph
          .clusters
          .each_with_object({}) { |(community_id, cluster), mapping| cluster.vertices.each { |vertex| mapping[vertex.id] = community_id } }

        # Iterate over all communities
        graph.clusters.each_value do |cluster|
          # Create a new vertex for the (non-empty) community
          reduced_graph.add_vertex(cluster.id) if cluster.vertices.any?
        end

        # Iterate over all combinations of vertices
        weights = graph.vertices.keys.combination(2).filter_map do |v1, v2|
          # Find all edges between the two vertices
          edges = Set.new(graph.find_edges(v1, v2) + graph.find_edges(v2, v1))

          # Skip if there are no edges
          next if edges.empty?

          # Find the communities of the vertices
          c1 = reduced_mapping[v1]
          c2 = reduced_mapping[v2]

          # Skip if the communities are the same
          next if c1 == c2

          # Calculate the weight for the aggregate edge
          weight = edges.sum { |e| e.attributes.fetch(:weight, 0.0) }

          [[c1, c2].sort, weight]
        end

        # Transform weights into a hash
        weights = weights
          .group_by(&:first)
          .transform_values { |es| es.sum(&:last) }

        # Add new edges to the reduced graph
        reduced_graph.vertices.keys.combination(2).each do |v1, v2|
          weight = weights.fetch([v1, v2], 0.0) + weights.fetch([v2, v1], 0.0)

          # Skip if the weight is zero
          next if weight.zero?

          reduced_graph
            .add_edge(v1, v2, weight:)
        end

        # Return the reduced graph and mapping
        [reduced_graph, reduced_mapping]
      end

      def modularity_for(graph)
        Metrics::Modularity
          .new(options, graph)
          .evaluate
      end
    end
  end
end
