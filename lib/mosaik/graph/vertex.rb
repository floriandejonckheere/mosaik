# frozen_string_literal: true

module MOSAIK
  module Graph
    class Vertex
      attr_reader :value, :edges

      def initialize(value, edges = {})
        @value = value
        @edges = edges
      end

      def add_edge(to, weight = nil)
        edges[to] = weight
      end

      def remove_edge(value)
        edges.delete(value)
      end

      def inspect
        "#<#{self.class.name} value=#{value} edges=[#{edges.join(', ')}]>"
      end
    end
  end
end
