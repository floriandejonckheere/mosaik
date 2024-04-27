# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Evaluate microservice candidates
    #
    class Evaluate < Command::Graph
      self.description = "Evaluate microservice candidates"

      defaults input: "mosaik-candidates.csv",
               output: "mosaik-evaluation.csv",
               metrics: [:abc_size, :cohesion, :complexity, :coupling, :modularity],
               statistics: nil

      argument("--metrics METRICS", Array, "Metrics to evaluate (default: #{defaults[:metrics].join(',')})") { |arg| arg&.map(&:to_sym) }
      argument "--statistics STATISTICS", "File for the statistics (default: #{defaults[:statistics].inspect})"

      def validate
        super

        raise OptionError, "input file not found: #{options[:input]}" unless File.exist? options[:input]

        metrics = options[:metrics] - self.class.defaults[:metrics]

        raise OptionError, "unknown metrics: #{metrics.join(', ')}" unless metrics.empty?
      end

      def call
        info "Evaluating microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Evaluate metrics
        options[:metrics].each do |metric|
          Metrics
            .const_get(metric.to_s.camelize)
            .new(options, graph)
            .evaluate
        end

        # Print the clusters
        graph.clusters.each_value do |cluster|
          info "Cluster #{cluster.id} (#{options[:metrics].map { |m| "#{m}: #{cluster.attributes[m].round(2)}" }.join(', ')})"

          next unless options[:debug]

          debug "Cluster #{cluster.id}: #{cluster.vertices.map(&:id).join(', ')}"
        end

        # Print the graph
        info "Graph (#{options[:metrics].map { |m| "#{m}: #{graph.attributes[m].round(2)}" }.join(', ')})"

        # Write graph to file
        write_graph

        # Render graph visualization
        visualize_graph

        return unless options[:statistics]

        # Compute statistics
        statistics = Graph::Statistics
          .new(options, graph)
          .call

        # Write statistics to file
        File.write(options[:statistics], statistics.to_yaml)

        info "Statistics written to #{options[:statistics]}"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:input]))
      end
    end
  end
end
