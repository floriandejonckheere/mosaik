# frozen_string_literal: true

module MOSAIK
  module Metrics
    ##
    # Cyclomatic complexity (T.J. McCabe, 1976)
    #
    class Complexity < Metric
      def evaluate
        # Total complexity
        complexity = 0.0

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices

          # Calculate complexity for the cluster
          complexity_c = 0.0

          # Iterate over all vertices in the cluster
          vertices_in_cluster.each do |v|
            # Resolve the constant name to a file
            file = resolver.resolve_constant!(v.id)

            # Parse file to extract complexities
            complexities = Parser
              .new
              .parse(file)

            # Calculate the complexity for the vertex
            complexity_v = complexities.any? ? (complexities.values.sum.to_f / complexities.size).round(2) : 0.0

            # Store complexity value in the vertex
            v.attributes[:complexity] = complexity_v

            # Store complexity value in the cluster
            complexity_c += complexity_v
          end

          # Store complexity value in the cluster
          cluster.attributes[:complexity] = complexity_c

          # Calculate complexity contribution from this cluster
          complexity += complexity_c
        end

        # Store complexity value in the graph
        graph.attributes[:complexity] = complexity

        # Return the total complexity
        complexity
      end

      private

      def resolver
        @resolver ||= Resolver.new(
          options[:directory],
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
        )
      end
    end
  end
end
