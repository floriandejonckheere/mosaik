# frozen_string_literal: true

# typed: strict

require "csv"

module MOSAIK
  module Graph
    ##
    # Simple implementation of an (un-)directed graph
    #
    class Graph
      extend T::Sig

      sig { returns(T::Boolean) }
      attr_reader :directed

      sig { returns(T::Hash[String, Vertex]) }
      attr_reader :vertices

      sig { returns(T::Hash[String, Cluster]) }
      attr_reader :clusters

      sig { returns(Attributes) }
      attr_reader :attributes

      sig { params(attributes: Attributes, directed: T::Boolean).void }
      def initialize(attributes = T.let({}, Attributes), directed: true)
        @attributes = attributes
        @directed = directed

        @vertices = T.let({}, T::Hash[String, Vertex])
        @clusters = T.let({}, T::Hash[String, Cluster])
      end

      alias directed? directed

      sig { params(id: String, attributes: Attributes).returns(Vertex) }
      def add_vertex(id, attributes = {})
        vertices[id] = Vertex.new(id, attributes)
      end

      sig { params(id: String).returns(T.nilable(Vertex)) }
      def find_vertex(id)
        vertices[id]
      end

      sig { params(id: String, attributes: Attributes).returns(Vertex) }
      def find_or_add_vertex(id, attributes = {})
        find_vertex(id) || add_vertex(id, attributes)
      end

      sig { params(id: String).void }
      def remove_vertex(id)
        vertices.delete(id)
      end

      sig { params(from: String, to: String, attributes: Attributes).returns(Edge) }
      def add_edge(from, to, attributes = {})
        # Add the edge in the given direction
        edge = T.must(vertices[from]).add_edge(to, **attributes)

        return edge if directed?

        # Add the same edge in the other direction
        T.must(vertices[to]).edges[from] = T.must(vertices[from]).edges.fetch(to)
      end

      sig { params(from: String, to: String).returns(T.nilable(Edge)) }
      def find_edge(from, to)
        T.must(vertices[from]).edges[to] if T.must(vertices[from]).edges.key?(to)
      end

      sig { params(from: String, to: String).returns(Edge) }
      def find_or_add_edge(from, to)
        find_edge(from, to) || add_edge(from, to)
      end

      sig { params(from: String, to: String).void }
      def remove_edge(from, to)
        T.must(vertices[from]).remove_edge(to)

        return if directed?

        T.must(vertices[to]).remove_edge(from)
      end

      sig { params(id: String, attributes: Attributes).returns(Cluster) }
      def add_cluster(id, attributes = {})
        clusters[id] = Cluster.new(id, attributes)
      end

      sig { params(id: String).returns(T.nilable(Cluster)) }
      def find_cluster(id)
        clusters[id]
      end

      sig { params(id: String, attributes: Attributes).returns(Cluster) }
      def find_or_add_cluster(id, attributes = {})
        clusters[id] || add_cluster(id, attributes)
      end

      sig { returns(Numeric) }
      def total_weight
        vertices
          .values
          .flat_map { |v| v.edges.values }
          .compact
          .to_set
          .sum { |e| e.attributes.fetch(:weight, 0.0) }
      end

      sig { returns(String) }
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
                edge.attributes.any? ? " [label=\"#{edge.attributes.map { |ek, ev| "#{ek}: #{ev}" }.join(', ')}\"]" : nil,
              ].compact.join
            end.compact_blank.join("\n  ")
          end.compact_blank.join("\n  ").prepend("  "),
          "}\n",
        ].compact.join("\n")
      end

      sig { params(file: String).void }
      def to_png(file)
        File.write("#{file}.dot", to_dot)
        system("dot -Tpng #{file}.dot -o #{file}.png")
      end

      sig { returns(String) }
      def to_csv
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        # rubocop:disable Metrics/BlockLength
        CSV.generate do |csv|
          # VERTICES
          # Collect all vertex attributes
          attributes = vertices
            .values
            .flat_map(&:attributes)
            .flat_map(&:keys)
            .uniq

          # Header
          csv << ["id", *attributes]

          # Add vertices using a vertex list
          vertices.each do |vertex_id, vertex|
            csv << [vertex_id, *attributes.map { |attr| vertex.attributes[attr] }]
          end

          # Separator
          csv << ["--"]

          # EDGES
          # Collect all edge attributes
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

          # CLUSTERS
          # Separator
          csv << ["--"]

          # VERTICES
          # Collect all vertex attributes
          attributes = clusters
            .values
            .flat_map(&:attributes)
            .flat_map(&:keys)
            .uniq

          # Header
          csv << ["vertex", "cluster", *attributes]

          # Add clusters using a cluster mapping
          clusters.each do |cluster_id, cluster|
            cluster.vertices.each do |vertex|
              csv << [vertex.id, cluster_id, *attributes.map { |attr| cluster.attributes[attr] }]
            end
          end
        end
        # rubocop:enable Metrics/BlockLength
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} vertices=#{vertices.values.map(&:inspect)}>"
      end

      sig { params(csv: String, directed: T::Boolean).returns(Graph) }
      def self.from_csv(csv, directed: true)
        graph = new(directed:)

        vertices, edges, clusters = csv.split("\n--\n")

        # Add vertices from the vertex list
        CSV.new(vertices, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { id:, **attributes }

          graph.find_or_add_vertex(id, attributes.symbolize_keys)
        end

        # Add edges from the adjacency list
        CSV.new(edges, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { from:, to:, **attributes }

          graph.find_or_add_vertex(from)
          graph.find_or_add_vertex(to)

          graph.add_edge(from, to, attributes.symbolize_keys)
        end

        return graph unless clusters

        # Add clusters from the cluster mapping
        CSV.new(clusters, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { vertex:, cluster:, **attributes }

          graph
            .find_or_add_cluster(cluster, attributes.symbolize_keys)
            .add_vertex(graph.find_or_add_vertex(vertex))
        end

        graph
      end
    end
  end
end
