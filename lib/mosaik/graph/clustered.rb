# frozen_string_literal: true

module MOSAIK
  module Graph
    ##
    # Clustered undirected graph
    #
    class Clustered
      attr_reader :clusters

      def initialize
        @clusters = Hash.new { |h, k| h[k] = [] }
      end

      def add_cluster(cluster_id)
        clusters[cluster_id]
      end

      def add_component(cluster_id, component_id)
        clusters[cluster_id] << component_id
      end

      def to_dot
        <<~DOT
          graph {
            #{clusters.keys.map { |cluster_id| subgraph(cluster_id) }.join("\n  ")}
          }
        DOT
      end

      def to_png(file)
        File.write("#{file}.dot", to_dot)
        system("dot -Tpng #{file}.dot -o #{file}.png")
      end

      private

      def subgraph(cluster_id)
        <<~DOT
          subgraph "cluster_#{cluster_id}" {
              label = "Cluster #{cluster_id}"
              color = "lightblue"

              node [shape=circle, style=filled, fillcolor=lightblue]

            #{clusters[cluster_id].map { |component_id| "  \"#{component_id}\" -- \"#{cluster_id}\"" }.join("\n  ")}
            }
        DOT
      end
    end
  end
end
