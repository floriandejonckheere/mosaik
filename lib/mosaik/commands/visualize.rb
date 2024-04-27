# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Render graph visualization
    #
    class Visualize < Command::Graph
      self.description = "Visualize graph as SVG file"

      defaults input: "mosaik.csv",
               output: "mosaik.svg"

      def validate
        super

        raise OptionError, "input file not found: #{options[:input]}" unless File.exist? options[:input]

        # Force visualization
        options[:visualize] = true

        # Remove output file extension
        options[:output] = options[:output].sub(/\.\w+$/, "")
      end

      def call
        info "Visualizing graph (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Render graph visualization
        visualize_graph
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:input]))
      end
    end
  end
end
