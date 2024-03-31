# frozen_string_literal: true

module MOSAIK
  module Graph
    ##
    # Edge in the graph
    #
    class Edge
      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = attributes
      end

      def inspect
        "#<#{self.class.name} attributes=#{attributes.map { |k, v| "#{k}: #{v}" }.join(',')}>"
      end
    end
  end
end
