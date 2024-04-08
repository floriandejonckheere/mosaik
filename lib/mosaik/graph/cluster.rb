# frozen_string_literal: true

module MOSAIK
  module Graph
    ##
    # Cluster of vertices
    #
    class Cluster
      attr_reader :id, :vertices

      def initialize(id)
        @id = id
        @vertices = Set.new
      end

      def add_vertex(vertex)
        vertices << vertex
      end

      def remove_vertex(vertex)
        vertices.delete(vertex)
      end

      def inspect
        "#<#{self.class.name} id=#{id} vertices=#{vertices.count}>"
      end
    end
  end
end
