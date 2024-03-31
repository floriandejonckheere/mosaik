# frozen_string_literal: true

module MOSAIK
  module Graph
    class Vertex
      attr_reader :id, :edges

      def initialize(id, edges = {})
        @id = id
        @edges = edges
      end

      def add_edge(to, weight = nil)
        edges[to] = weight
      end

      def remove_edge(id)
        edges.delete(id)
      end

      def inspect
        "#<#{self.class.name} id=#{id} edges=[#{edges.join(', ')}]>"
      end
    end
  end
end
