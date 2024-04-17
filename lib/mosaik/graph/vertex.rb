# frozen_string_literal: true

# typed: strict

module MOSAIK
  module Graph
    ##
    # Vertex in the graph
    #
    class Vertex
      extend T::Sig

      sig { returns(String) }
      attr_reader :id

      sig { returns(T::Hash[String, T::Array[Edge]]) }
      attr_reader :edges

      sig { returns(Attributes) }
      attr_reader :attributes

      sig { params(id: String, attributes: Attributes).void }
      def initialize(id, attributes = {})
        @id = id
        @edges = T.let(Hash.new { |h, k| h[k] = [] }, T::Hash[String, T::Array[Edge]])
        @attributes = attributes
      end

      sig { params(to: String, attributes: Attributes).returns(Edge) }
      def add_edge(to, attributes = {})
        edge = Edge.new(attributes)

        T.must(edges[to]) << edge

        edge
      end

      sig { params(id: String, edge: T.nilable(Edge)).void }
      def remove_edge(id, edge = nil)
        if edge.nil?
          edges.delete(id)
        else
          edges[id].delete(edge)
        end
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} id=#{id} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')} edges=#{edges.count}>"
      end
    end
  end
end
