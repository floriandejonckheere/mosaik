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

          mean = values.any? ? (values.sum.to_f / values.size) : 0.0
          variance = values.any? ? (values.sum { |v| (v - mean)**2 } / values.size) : 0.0

          statistics = {
            min: values.min || 0.0,
            max: values.max || 0.0,
            mean:,
            variance:,
            stdev: Math.sqrt(variance),
            q1: percentile(values, 25) || 0.0,
            q2: percentile(values, 50) || 0.0,
            q3: percentile(values, 75) || 0.0,
          }

          debug "Statistics for #{metric}: #{statistics.map { |k, v| "#{k} = #{v&.round(2)}" }.join(', ')}"

          [metric, statistics]
        end

        # Compute cluster statistics
        mean = graph.clusters.values.any? ? (graph.clusters.values.sum { |cluster| cluster.vertices.size }.to_f / graph.clusters.size) : 0.0
        variance = graph.clusters.values.any? ? (graph.clusters.values.sum { |cluster| (cluster.vertices.size - mean)**2 } / graph.clusters.size) : 0.0

        metrics[:clusters] = {
          count: graph.clusters.size,
          min: graph.clusters.values.map { |cluster| cluster.vertices.size }.min,
          max: graph.clusters.values.map { |cluster| cluster.vertices.size }.max,
          mean:,
          variance:,
          stdev: Math.sqrt(variance),
          size: graph.clusters.values.map { |cluster| cluster.vertices.size }.sort,
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
