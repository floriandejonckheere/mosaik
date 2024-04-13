# frozen_string_literal: true

# typed: true

module MOSAIK
  module Graph
    ##
    # Vertex in the graph
    #
    class Vertex
      extend T::Sig

      sig { returns(String) }
      attr_reader :id

      sig { returns(T::Hash[String, Edge]) }
      attr_reader :edges

      sig { returns(Attributes) }
      attr_reader :attributes

      sig { params(id: String, attributes: Attributes).void }
      def initialize(id, attributes = {})
        @id = id
        @edges = {}
        @attributes = attributes
      end

      sig { params(to: String, attributes: Attributes).returns(Edge) }
      def add_edge(to, attributes = {})
        edges[to] ||= Edge.new

        edges
          .fetch(to)
          .attributes
          .merge!(attributes)

        edges.fetch(to)
      end

      sig { params(id: String).void }
      def remove_edge(id)
        edges.delete(id)
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} id=#{id} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')} edges=#{edges.count}>"
      end
    end
  end
end
