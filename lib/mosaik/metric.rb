# frozen_string_literal: true

module MOSAIK
  class Metric
    attr_reader :options, :graph

    def initialize(options, graph)
      @options = options
      @graph = graph
    end

    def evaluate
      raise NotImplementedError
    end
  end
end
