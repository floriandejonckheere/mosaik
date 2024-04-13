# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Evaluate microservice candidates
    #
    class Evaluate < Command
      self.description = "Evaluate microservice candidates"

      defaults file: "mosaik-candidates.csv"

      argument "--file FILE", "File for the identified microservice candidates graph (default: #{defaults[:file]})"

      def validate
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
      end

      def call
        info "Evaluating microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Evaluate modularity
        Metrics::Modularity
          .new(options, graph)
          .evaluate

        # Print the clusters
        graph.clusters.each_value do |cluster|
          info "Cluster #{cluster.id} (modularity: #{cluster.attributes[:modularity]})"

          next unless options[:debug]

          debug "Components: #{cluster.vertices.map(&:id).join(', ')}"
        end

        file = "#{File.basename(options[:file], '.*')}-evaluation"

        # Write graph to file
        File.write("#{file}.csv", graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

        return unless options[:visualize]

        # Write visualization to file
        debug graph.to_dot
        graph.to_png(file)

        info "Evaluated microservice candidate graph written to #{file}.dot and rendered to #{file}.png"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
