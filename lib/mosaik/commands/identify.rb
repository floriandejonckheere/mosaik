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

        clustered_graph = Graph::Clustered.new

        # Add vertices to the clustered graph
        candidates.each do |vertex, cluster_id|
          clustered_graph.add_vertex(cluster_id, vertex)
        end

        # Print the identified microservice candidates
        debug graph

        return unless options[:visualize]

        dotfile = "#{File.basename(options[:file], '.*')}-candidates.dot"
        pngfile = "#{File.basename(options[:file], '.*')}-candidates.png"

        # Write visualization to file
        File.write(dotfile, graph)
        system("dot -Tpng #{dotfile} -o #{pngfile}")

        info "Microservice candidate graph written to #{dotfile} and rendered to #{pngfile}"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
