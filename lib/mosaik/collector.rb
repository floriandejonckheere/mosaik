# frozen_string_literal: true

module MOSAIK
  class Collector
    attr_reader :options, :graph

    def initialize(options, graph)
      @options = options
      @graph = graph
    end

    def call
      raise NotImplementedError
    end
  end
end
