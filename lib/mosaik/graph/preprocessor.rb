# frozen_string_literal: true

# typed: true

module MOSAIK
  module Graph
    ##
    # Preprocess the graph
    #
    class Preprocessor
      attr_reader :options, :graph

      def initialize(options, graph)
        @options = options
        @graph = graph
      end

      def call; end
    end
  end
end
