# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Identify microservice candidates
    #
    class Identify < Command
      self.description = "Identify microservice candidates"

      defaults file: "mosaik.csv"

      argument "--file FILE", "File for the extracted information graph (default: #{defaults[:file]})"

      def validate
        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
      end

      def call
        info "Identifying microservice candidates"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(options[:file])
      end
    end
  end
end
