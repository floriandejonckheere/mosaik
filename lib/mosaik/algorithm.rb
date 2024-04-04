# frozen_string_literal: true

module MOSAIK
  ##
  # Base class for algorithms
  #
  class Algorithm
    attr_reader :options, :graph

    def initialize(options, graph)
      @options = options
      @graph = graph
    end

    def validate; end

    def call
      raise NotImplementedError
    end
  end
end
