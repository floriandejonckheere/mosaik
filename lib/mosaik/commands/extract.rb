# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Extract information from the application
    #
    class Extract < Command
      self.description = "Extract information"

      defaults visualize: false,
               file: "mosaik.csv",
               structural: 1,
               logical: 1,
               contributor: 1,
               since: nil,
               limit: 100

      argument "--visualize", "Visualize the extracted information graph"
      argument "--file FILE", "File for the extracted information graph (default: #{defaults[:file]})"

      argument "--structural N", Float, "Weight of structural coupling extraction (default: #{defaults[:structural]})"
      argument "--logical N", Float, "Weight of logical coupling extraction (default: #{defaults[:logical]})"
      argument "--contributor N", Float, "Weight of coupling extraction (default: #{defaults[:contributor]})"

      # Evolution options
      argument "--since DATE", "Include only commits from a specific date"
      argument "--limit N", Integer, "Limit the number of commits to analyze (default: 100)"

      def validate
        raise OptionError, "negative value: #{options[:limit]}" if options[:limit].negative?
      end

      def call
        info "Extracting information from the codebase (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Add a vertex for each constant in the load path
        MOSAIK.configuration.files.each do |file|
          # Resolve file path to class name
          class_name = resolver.resolve(file)

          # Add class to graph
          graph.find_or_add_vertex(class_name)
        end

        # Extract structural coupling information and add to graph
        Extractors::Structural
          .new(options, graph)
          .tap(&:validate)
          .call

        # Extract evolutionary (logical and contributor) coupling information and add to graph
        Extractors::Evolution
          .new(options, graph)
          .tap(&:validate)
          .call

        # Write graph to file
        File.write(options[:file], graph.to_csv)

        info "Graph written to #{options[:file]}"

        return unless options[:visualize]

        # Write graph to file
        debug graph.to_dot
        graph.to_png("mosaik")

        info "Graph written to mosaik.dot and rendered to mosaik.png"
      end

      private

      def graph
        @graph ||= Graph::Graph.new
      end

      def resolver
        @resolver ||= Resolver.new(
          options[:directory],
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
        )
      end
    end
  end
end
