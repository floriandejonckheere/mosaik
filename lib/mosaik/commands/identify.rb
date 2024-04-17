# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Identify microservice candidates
    #
    class Identify < Command
      self.description = "Identify microservice candidates"

      defaults structural: 1,
               logical: 1,
               contributor: 1,
               file: "mosaik.csv",
               algorithm: "louvain"

      argument "--structural N", Float, "Weight of structural coupling (default: #{defaults[:structural]})"
      argument "--logical N", Float, "Weight of logical coupling (default: #{defaults[:logical]})"
      argument "--contributor N", Float, "Weight of contributor coupling (default: #{defaults[:contributor]})"

      argument "--file FILE", "File for the extracted information graph (default: #{defaults[:file]})"
      argument "--algorithm ALGORITHM", "Algorithm to use for identifying microservice candidates (default: #{defaults[:algorithm]})"

      def validate
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
        raise OptionError, "unknown algorithm: #{options[:algorithm]}" unless options[:algorithm].in? ["louvain"]
      end

      def call
        info "Identifying microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Preprocess the graph (aggregate edges and normalize weights)
        Graph::Preprocessor
          .new(options, graph)
          .call

        # Identify microservice candidates
        Algorithms
          .const_get(options[:algorithm].camelize)
          .new(options, graph)
          .tap(&:validate)
          .call

        # Print the clusters
        graph.clusters.each_value do |cluster|
          debug "Cluster #{cluster.id}"
          cluster.vertices.each do |vertex|
            debug "  #{vertex.id}"
          end
        end

        file = "#{File.basename(options[:file], '.*')}-candidates"

        # Write graph to file
        File.write("#{file}.csv", graph.to_csv)

        info "Dependency graph written to #{options[:file]}"

        return unless options[:visualize]

        # Write visualization to file
        debug graph.to_dot
        graph.to_svg(file)

        info "Microservice candidate graph written to #{file}.dot and rendered to #{file}.svg"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
