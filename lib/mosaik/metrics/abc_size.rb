# frozen_string_literal: true

module MOSAIK
  module Metrics
    ##
    # ABC Size (J. Fitzpatrick, 1997)
    #
    class ABCSize < Metric
      def evaluate
        # Total ABC size
        abc_size = 0.0

        # Iterate over each cluster
        graph.clusters.each_value do |cluster|
          # Find all vertices in the cluster
          vertices_in_cluster = cluster.vertices

          # Calculate ABC size for the cluster
          abc_size_c = 0.0

          # Iterate over all vertices in the cluster
          vertices_in_cluster.each do |v|
            # Resolve the constant name to a file
            file = resolver.resolve_constant(v.id)

            warn "Could not resolve constant #{v.id}" and next unless file
            warn "#{v.id} (#{file}) is a directory" and next if File.directory?(file)

            # Parse file to extract ABC sizes
            abc_sizes = Parser
              .new
              .parse(file)

            # Calculate the ABC size for the vertex
            abc_size_v = abc_sizes.any? ? (abc_sizes.values.sum.to_f / abc_sizes.size) : 0.0

            # Store ABC size value in the vertex
            v.attributes[:abc_size] = abc_size_v

            # Store ABC size value in the cluster
            abc_size_c += abc_size_v
          end

          # Store ABC size value in the cluster
          cluster.attributes[:abc_size] = abc_size_c

          # Calculate ABC size contribution from this cluster
          abc_size += abc_size_c
        end

        # Store ABC size value in the graph
        graph.attributes[:abc_size] = abc_size

        # Return the total ABC size
        abc_size
      end

      private

      def resolver
        @resolver ||= Resolver.new(
          options[:directory],
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
          MOSAIK.configuration.collapsed,
        )
      end
    end
  end
end
