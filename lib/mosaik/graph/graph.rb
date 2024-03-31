# frozen_string_literal: true

require "tsort"

module MOSAIK
  module Graph
    class Graph
      include TSort

      attr_reader :vertices

      def initialize
        @vertices = {}
      end

      def add_vertex(id, attributes = {})
        vertices[id] = Vertex.new(id, attributes)
      end

      def add_directed_edge(from, to, attributes = {})
        vertices[from].add_edge(to, **attributes)
      end
      alias add_edge add_directed_edge

      def add_undirected_edge(from, to, attributes = {})
        vertices[from].add_edge(to, **attributes)
        vertices[to].add_edge(from, **attributes)
      end

      def remove_directed_edge(from, to)
        vertices[from].remove_edge(to)
      end
      alias remove_edge remove_directed_edge

      def remove_undirected_edge(from, to)
        vertices[from].remove_edge(to)
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

      def inspect
        "#<#{self.class.name} vertices=#{vertices.each_value.map(&:inspect)}>"
      end
    end
  end
end
