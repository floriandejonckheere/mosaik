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
        Algorithms
          .const_get(options[:algorithm].camelize)
          .new(options, graph)
          .tap(&:validate)
          .call
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
