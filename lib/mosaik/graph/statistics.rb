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
        # Compute metric statistics
        metrics = options[:metrics].to_h do |metric|
          values = graph.clusters.each_value.map { |cluster| cluster.attributes[metric] }

          # Drop zero values
          values = values.reject { |v| v.nil? || v.zero? }

          statistics = {
            min: values.min,
            max: values.max,
            mean: values.sum.to_f / values.size,
            q1: percentile(values, 25),
            q2: percentile(values, 50),
            q3: percentile(values, 75),
          }

          debug "Statistics for #{metric}: #{statistics.map { |k, v| "#{k} = #{v&.round(2)}" }.join(', ')}"

          [metric, statistics]
        end

        # Compute cluster statistics
        metrics[:clusters] = {
          count: graph.clusters.size,
          min: graph.clusters.values.map { |cluster| cluster.vertices.size }.min,
          max: graph.clusters.values.map { |cluster| cluster.vertices.size }.max,
          size: graph.clusters.values.map { |cluster| cluster.vertices.size },
        }

        # Return statistics
        metrics.deep_stringify_keys
      end

      private

      def percentile(values, percentile)
        values.sort[(percentile * values.size / 100.0).ceil - 1]
      end
    end
  end
end
