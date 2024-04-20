# frozen_string_literal: true

require "yaml"

module MOSAIK
  module Graph
    ##
    # Compute statistics
    #
    class Statistics
      attr_reader :options, :graph

      def initialize(options, graph)
        @options = options
        @graph = graph
      end

      def call
        # Compute statistics
        options[:metrics].to_h do |metric|
          values = graph.clusters.each_value.map { |cluster| cluster.attributes[metric] }

          [
            metric,
            min: values.min,
            max: values.max,
            mean: values.sum.to_f / values.size,
            q1: percentile(values, 25),
            q2: percentile(values, 50),
            q3: percentile(values, 75),
          ]
        end.deep_stringify_keys
      end

      private

      def percentile(values, percentile)
        values.sort[(percentile * values.size / 100.0).ceil - 1]
      end
    end
  end
end
