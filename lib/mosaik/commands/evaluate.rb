# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Evaluate microservice candidates
    #
    class Evaluate < Command::Graph
      self.description = "Evaluate microservice candidates"

      defaults file: "mosaik-candidates.csv",
               metrics: [:modularity, :coupling]

      argument("--metrics METRICS", Array, "Metrics to evaluate (default: #{defaults[:metrics].join(',')})") { |arg| arg&.map(&:to_sym) }

      def validate
        super

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

        # Print the graph
        info "Graph (#{options[:metrics].map { |m| "#{m}: #{graph.attributes[m]}" }.join(', ')})"

        # Print the clusters
        graph.clusters.each_value do |cluster|
          info "Cluster #{cluster.id} (#{options[:metrics].map { |m| "#{m}: #{cluster.attributes[m]}" }.join(', ')})"

          next unless options[:debug]

          debug "Components: #{cluster.vertices.map(&:id).join(', ')}"
        end

        file = "#{File.basename(options[:file], '.*')}-evaluation"

        # Write graph to file
        File.write("#{file}.csv", graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

        return unless options[:visualize]

        # Write visualization to file
        debug graph.to_dot(options)
        graph.to_png(file, options)

        info "Evaluated microservice candidate graph written to #{file}.gv and rendered to #{file}.png"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
