# frozen_string_literal: true

# typed: strict

module MOSAIK
  module Graph
    ##
    # Cluster of vertices
    #
    class Cluster
      extend T::Sig

      sig { returns(String) }
      attr_reader :id

      sig { returns(T::Set[Vertex]) }
      attr_reader :vertices

      sig { returns(Attributes) }
      attr_reader :attributes

      sig { params(id: String, attributes: Attributes).void }
      def initialize(id, attributes = T.let({}, Attributes))
        @attributes = attributes
        @id = id
        @vertices = T.let(Set.new, T::Set[Vertex])
      end

      sig { params(vertex: Vertex).void }
      def add_vertex(vertex)
        vertices << vertex
      end

      sig { params(vertex: Vertex).void }
      def remove_vertex(vertex)
        vertices.delete(vertex)
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} id=#{id} vertices=#{vertices.size} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')}>"
      end
    end
  end
end
