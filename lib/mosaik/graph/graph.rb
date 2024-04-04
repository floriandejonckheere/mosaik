# frozen_string_literal: true

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

      def inspect
        "#<#{self.class.name} vertices=#{vertices.values.map(&:inspect)}>"
      end
    end
  end
end
