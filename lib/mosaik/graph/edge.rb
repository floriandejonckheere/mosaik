# frozen_string_literal: true

# typed: strict

module MOSAIK
  module Graph
    ##
    # Edge in the graph
    #
    class Edge
      extend T::Sig

      sig { returns(Attributes) }
      attr_reader :attributes

      sig { params(attributes: Attributes).void }
      def initialize(attributes = T.let({}, Attributes))
        @attributes = attributes
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')}>"
      end
    end
  end
end
