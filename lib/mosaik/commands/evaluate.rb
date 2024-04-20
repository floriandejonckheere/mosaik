# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Evaluate microservice candidates
    #
    class Evaluate < Command::Graph
      self.description = "Evaluate microservice candidates"

      defaults file: "mosaik-candidates.csv",
               metrics: [:abc_size, :cohesion, :complexity, :coupling, :modularity]

      argument("--metrics METRICS", Array, "Metrics to evaluate (default: #{defaults[:metrics].join(',')})") { |arg| arg&.map(&:to_sym) }

      def validate
        super

        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]

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

          debug "Components: #{cluster.vertices.map(&:id).join(', ')}"
        end

        # Print the graph
        info "Graph (#{options[:metrics].map { |m| "#{m}: #{graph.attributes[m].round(2)}" }.join(', ')})"

        # Change file name
        options[:file] = "#{File.basename(options[:file], '.*')}-evaluation.csv"

        # Write graph to file
        visualize
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
