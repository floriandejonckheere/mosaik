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

      VERSION = 1

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

      sig { params(file: String).void }
      def to_svg(file)
        File.write("#{file}.dot", to_dot)
        system("dot -Tsvg #{file}.dot -o #{file}.svg")
      end

      sig { returns(String) }
      def to_csv
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        # rubocop:disable Metrics/BlockLength
        CSV.generate do |csv|
          # PREAMBLE
          # Collect all graph attributes
          attrs = attributes
            .keys

          csv << ["directed", "version", *attrs]

          # Add graph attributes
          csv << [directed, VERSION, *attrs.map { |attr| attributes[attr] }]

          # Separator
          csv << ["--"]

          # VERTICES
          # Collect all vertex attributes
          attrs = vertices
            .values
            .flat_map(&:attributes)
            .flat_map(&:keys)
            .uniq

          # Header
          csv << ["id", *attrs]

          # Add vertices using a vertex list
          vertices.each do |vertex_id, vertex|
            csv << [vertex_id, *attrs.map { |attr| vertex.attributes[attr] }]
          end

          # Separator
          csv << ["--"]

          # EDGES
          # Collect all edge attributes
          attrs = vertices
            .values
            .flat_map { |v| v.edges.flat_map { |_, e| e.attributes.keys } }
            .uniq

          # Header
          csv << ["from", "to", *attrs]

          # Add vertices and edges using an adjacency list
          vertices.each do |vertex_id, vertex|
            vertex.edges.each do |edge_id, edge|
              next if edge.in? visited

              visited << edge

              csv << [vertex_id, edge_id, *attrs.map { |attr| edge.attributes[attr] }]
            end
          end

          next unless clusters.any?

          # CLUSTERS
          # Separator
          csv << ["--"]

          # VERTICES
          # Collect all vertex attributes
          attrs = clusters
            .values
            .flat_map(&:attributes)
            .flat_map(&:keys)
            .uniq

          # Header
          csv << ["vertex", "cluster", *attrs]

          # Add clusters using a cluster mapping
          clusters.each do |cluster_id, cluster|
            cluster.vertices.each do |vertex|
              csv << [vertex.id, cluster_id, *attrs.map { |attr| cluster.attributes[attr] }]
            end
          end
        end
        # rubocop:enable Metrics/BlockLength
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} vertices=#{vertices.values.map(&:inspect)}>"
      end

      sig { params(csv: String).returns(Graph) }
      def self.from_csv(csv)
        preamble, vertices, edges, clusters = csv.split("\n--\n")

        # Parse preamble
        CSV.parse_line(preamble, headers: true, header_converters: :symbol, converters: :numeric) => { directed:, version:, **attributes }

        raise Error, "Unsupported graph version: #{version}" unless version == VERSION

        # Create a new graph
        graph = new(attributes, directed: (directed == "true"))

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
