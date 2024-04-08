# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Identify microservice candidates
    #
    class Identify < Command
      self.description = "Identify microservice candidates"

      defaults file: "mosaik.csv",
               algorithm: "louvain"

      argument "--file FILE", "File for the extracted information graph (default: #{defaults[:file]})"
      argument "--algorithm ALGORITHM", "Algorithm to use for identifying microservice candidates (default: #{defaults[:algorithm]})"

      def validate
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
        raise OptionError, "unknown algorithm: #{options[:algorithm]}" unless options[:algorithm].in? ["louvain"]
      end

      def call
        info "Identifying microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Identify microservice candidates
        candidates = Algorithms
          .const_get(options[:algorithm].camelize)
          .new(options, graph)
          .tap(&:validate)
          .call

        # Add clusters to the graph
        candidates.each do |vertex, cluster_id|
          graph
            .find_or_add_cluster(cluster_id)
            .add_vertex(vertex)
        end

        file = "#{File.basename(options[:file], '.*')}-candidates"

        # Write graph to file
        File.write("#{file}.csv", graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

        return unless options[:visualize]

        # Write visualization to file
        debug graph.to_dot
        graph.to_png(file)

        info "Microservice candidate graph written to #{file}.dot and rendered to #{file}.png"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
