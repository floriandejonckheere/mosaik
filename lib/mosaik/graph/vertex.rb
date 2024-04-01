# frozen_string_literal: true

module MOSAIK
  module Graph
    ##
    # Vertex in the graph
    #
    class Vertex
      attr_reader :id, :edges, :attributes

      def initialize(id, attributes = {})
        @id = id
        @edges = Hash.new { |h, k| h[k] = Edge.new }
        @attributes = attributes
      end

      def add_edge(to, **attributes)
        edges[to].attributes.merge!(attributes)
      end

      def remove_edge(id)
        edges.delete(id)
      end

      def inspect
        "#<#{self.class.name} id=#{id} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')} edges=#{edges.count}>"
      end
    end
  end
end
