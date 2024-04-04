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

      attr_reader :directed, :vertices

      def initialize(directed: true)
        @directed = directed
        @vertices = {}
      end

      alias directed? directed

      def add_vertex(id, attributes = {})
        vertices[id] = Vertex.new(id, attributes)
      end

      def add_edge(from, to, attributes = {})
        # Add the edge in the given direction
        vertices[from].add_edge(to, **attributes)

        return if directed?

        # Add the same edge in the other direction
        vertices[to].edges[from] = vertices[from].edges[to]
      end

      def remove_edge(from, to)
        vertices[from].remove_edge(to)

        return if directed?

        vertices[to].remove_edge(from)
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

      def total_weight
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        vertices.values.sum do |vertex|
          vertex.edges.values.sum do |edge|
            next if edge.in? visited

            visited << edge

            edge.attributes.fetch(:weight, 0)
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

        <<~DOT
          #{directed ? 'digraph' : 'graph'} {
            #{
              vertices
                .values
                .flat_map do |vertex|
                vertex
                  .edges
                  .filter_map do |key, edge|
                  next if edge.in? visited

                  visited << edge

                  dot = "\"#{vertex.id}\" -#{directed? ? '>' : '-'} \"#{key}\""
                  dot = "#{dot} [label=\"#{edge.attributes.map { |ek, ev| "#{ek}: #{ev}" }.join(', ')}\"]" if edge.attributes.any?

                  dot
                end
              end
              .join("\n  ")
            }
          }
        DOT
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

          # Data
          vertices.each do |vertex_id, vertex|
            vertex.edges.each do |edge_id, edge|
              next if edge.in? visited

              visited << edge

              csv << [vertex_id, edge_id, *attributes.map { |attr| edge.attributes[attr] }]
            end
          end
        end
      end

      def inspect
        "#<#{self.class.name} vertices=#{vertices.values.map(&:inspect)}>"
      end

      def self.from_csv(csv, directed: true)
        graph = new(directed:)

        CSV.new(csv, headers: true, header_converters: :symbol, converters: :numeric).each do |row|
          row => { from:, to:, **attributes }

          graph.find_or_add_vertex(from)
          graph.find_or_add_vertex(to)

          graph.add_edge(from, to, attributes.symbolize_keys)
        end

        graph
      end
    end
  end
end
