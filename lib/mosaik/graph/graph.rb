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

      def add_vertex(vertex)
        vertices[vertex.value] = vertex
      end

      def add_directed_edge(from, to, weight = nil)
        vertices[from.value].add_edge(to, weight)
      end
      alias add_edge add_directed_edge

      def add_undirected_edge(from, to, weight = nil)
        vertices[from.value].add_edge(to, weight)
        vertices[to.value].add_edge(from, weight)
      end

      def remove_directed_edge(from, to)
        vertices[from.value].remove_edge(to)
      end
      alias remove_edge remove_directed_edge

      def remove_undirected_edge(from, to)
        vertices[from.value].remove_edge(to)
        vertices[to.value].remove_edge(from)
      end

      def find_vertex(value)
        vertices[value]
      end

      def remove_vertex(vertex)
        vertices.delete(vertex.value)
      end

      def tsort_each_node(&)
        vertices.keys.each(&)
      end

      def tsort_each_child(vertex, &)
        vertices[vertex].edges.each(&)
      end

      def inspect
        "#<#{self.class.name} vertices=#{vertices.each_value.map(&:inspect)}>"
      end
    end
  end
end
