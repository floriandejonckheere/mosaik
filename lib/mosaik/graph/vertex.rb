# frozen_string_literal: true

module MOSAIK
  module Graph
    class Vertex
      attr_reader :value, :edges

      def initialize(value, edges = {})
        @value = value
        @edges = edges
      end

      def add_edge(vertex, weight = nil)
        edges[vertex.value] = weight
      end

      def remove_edge(vertex)
        edges.delete(vertex.value)
      end

      def inspect
        "#<#{self.class.name} value=#{value} edges=[#{edges.join(', ')}]>"
      end
    end
  end
end
