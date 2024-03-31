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

      def add_vertex(id)
        vertices[id] = Vertex.new(id)
      end

      def add_directed_edge(from, to, weight = nil)
        vertices[from].add_edge(to, weight)
      end
      alias add_edge add_directed_edge

      def add_undirected_edge(from, to, weight = nil)
        vertices[from].add_edge(to, weight)
        vertices[to].add_edge(from, weight)
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

      def find_or_add_vertex(id)
        find_vertex(id) || add_vertex(id)
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
