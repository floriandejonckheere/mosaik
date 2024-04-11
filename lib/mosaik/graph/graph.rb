# frozen_string_literal: true

require "csv"
require "tsort"

module MOSAIK
  module Graph
    ##
    # Simple implementation of an (un-)directed graph
    #
    class Graph
      include TSort

      attr_reader :directed, :vertices, :clusters

      def initialize(directed: true)
        @directed = directed
        @vertices = {}
        @clusters = {}
      end

      alias directed? directed

      def add_vertex(id, attributes = {})
        vertices[id] = Vertex.new(id, attributes)
      end

      def find_vertex(id)
        vertices[id]
      end

      def find_or_add_vertex(id, attributes = {})
        find_vertex(id) || add_vertex(id, attributes)
      end

      def remove_vertex(id)
        vertices.delete(id)
      end

      def add_edge(from, to, attributes = {})
        # Add the edge in the given direction
        vertices[from].add_edge(to, **attributes)

        return if directed?

        # Add the same edge in the other direction
        vertices[to].edges[from] = vertices[from].edges[to]
      end

      def find_edge(from, to)
        vertices[from].edges[to] if vertices[from].edges.key?(to)
      end

      def find_or_add_edge(from, to)
        vertices[from].edges[to]
      end

      def remove_edge(from, to)
        vertices[from].remove_edge(to)

        return if directed?

        vertices[to].remove_edge(from)
      end

      def add_cluster(id)
        clusters[id] = Cluster.new(id)
      end

      def find_cluster(id)
        clusters[id]
      end

      def find_or_add_cluster(id)
        clusters[id] || add_cluster(id)
      end

      def total_weight
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        vertices.values.sum do |vertex|
          vertex.edges.values.sum do |edge|
            next if edge.in? visited

            visited << edge

            edge.attributes.fetch(:weight, 0.0)
          end
        end
      end

      def tsort_each_node(&)
        vertices.values.each(&)
      end

      def tsort_each_child(vertex, &)
        vertices[vertex.id].edges.each_key do |key|
          yield vertices[key]
        end
      end

      def to_dot
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        [
          directed ? "digraph {" : "graph {",
          (if clusters.any?
             clusters
              .values
              .filter_map do |cluster|
               [
                 "subgraph \"#{cluster.id}\" {",
                 "  cluster = true",
                 "  label = \"#{cluster.id}\"",
                 '  color = "lightblue"',
                 "  node [shape=circle, style=filled, fillcolor=lightblue]",
                 *cluster.vertices.map { |vertex| "  \"#{vertex.id}\"" },
                 "}",
               ]
             end.join("\n  ").prepend("  ")
           end),
          vertices
            .values
            .map do |vertex|
            vertex
              .edges
              .map do |key, edge|
              next if edge.in? visited

              visited << edge

              [
                "\"#{vertex.id}\" ",
                directed? ? "->" : "--",
                " \"#{key}\"",
                edge.attributes.any? ? " [label=\"#{edge.attributes.map { |ek, ev| "#{ek}: #{ev.respond_to?(:each) ? ev.join(',') : ev}" }.join(', ')}\"]" : nil,
              ].compact.join
            end.compact_blank.join("\n  ")
          end.compact_blank.join("\n  ").prepend("  "),
          "}\n",
        ].compact.join("\n")
      end

      def to_png(file)
        File.write("#{file}.dot", to_dot)
        system("dot -Tpng #{file}.dot -o #{file}.png")
      end

      def to_csv
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        CSV.generate do |csv|
          # Collect all attributes
          attributes = vertices
            .values
            .flat_map { |v| v.edges.flat_map { |_, e| e.attributes.keys } }
            .uniq

          # Header
          csv << ["from", "to", *attributes]

          # Add vertices and edges using an adjacency list
          vertices.each do |vertex_id, vertex|
            vertex.edges.each do |edge_id, edge|
              next if edge.in? visited

              visited << edge

              csv << [vertex_id, edge_id, *attributes.map { |attr| edge.attributes[attr] }]
            end
          end

          next unless clusters.any?

          # Separator
          csv << ["--"]

          # Header
          csv << ["vertex", "cluster"]

          # Add clusters using a cluster mapping
          clusters.each do |cluster_id, cluster|
            cluster.vertices.each do |vertex|
              csv << [vertex.id, cluster_id]
            end
          end
        end
      end

      def inspect
        "#<#{self.class.name} vertices=#{vertices.values.map(&:inspect)}>"
      end

      def self.from_csv(csv, directed: true)
        graph = new(directed:)

        vertices, clusters = csv.split("\n--\n")

        # Add vertices and edges from the adjacency list
        CSV.new(vertices, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { from:, to:, **attributes }

          graph.find_or_add_vertex(from)
          graph.find_or_add_vertex(to)

          graph.add_edge(from, to, attributes.symbolize_keys)
        end

        return graph unless clusters

        # Add clusters from the cluster mapping
        CSV.new(clusters, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { vertex:, cluster: }

          graph
            .find_or_add_cluster(cluster)
            .add_vertex(graph.find_or_add_vertex(vertex))
        end

        graph
      end
    end
  end
end
