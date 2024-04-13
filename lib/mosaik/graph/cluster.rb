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

      sig { params(id: String).void }
      def initialize(id)
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
        "#<#{self.class.name} id=#{id} vertices=#{vertices.count}>"
      end
    end
  end
end
