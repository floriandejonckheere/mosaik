# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Extract information from the application
    #
    class Extract < Command::Graph
      self.description = "Extract information"

      defaults input: nil,
               output: "mosaik.csv",
               couplings: [:structural, :logical, :contributor],
               since: nil,
               limit: 100

      argument("--couplings COUPLINGS", Array, "Coupling information to extract (default: #{defaults[:couplings].join(',')})") { |arg| arg&.map(&:to_sym) }

      # Evolution options
      argument "--since DATE", "Include only commits from a specific date"
      argument "--limit N", Integer, "Limit the number of commits to analyze (default: 100)"

      def validate
        super

        couplings = options[:couplings] - self.class.defaults[:couplings]

        raise OptionError, "unknown coupling: #{couplings.join(', ')}" unless couplings.empty?

        raise OptionError, "negative value: #{options[:limit]}" if options[:limit].negative?

        options[:limit] = nil if options[:limit].zero?
      end

      def call
        info "Extracting information from the codebase (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        warn "No files found in the load paths, check if a valid mosaik.yml file exists in #{options[:directory]}" if MOSAIK.configuration.files.empty?

        # Add a vertex for each constant in the load path
        MOSAIK.configuration.files.each do |file|
          # Resolve file path to class name
          class_name = resolver.resolve_file(file)

          # Add class to graph
          graph.find_or_add_vertex(class_name)
        end

        # Extract structural coupling information and add to graph
        if options[:couplings].include?(:structural)
          Extractors::Structural
            .new(options, graph)
            .tap(&:validate)
            .call
        end

        # Extract evolutionary (logical and contributor) coupling information and add to graph
        if options[:couplings].include?(:logical) || options[:couplings].include?(:contributor)
          Extractors::Evolution
            .new(options, graph)
            .tap(&:validate)
            .call
        end

        # Write graph to file
        write_graph

        # Render graph visualization
        visualize_graph
      end

      private

      def graph
        @graph ||= Graph::Graph.new(directed: true)
      end

      def resolver
        @resolver ||= Resolver.new(
          options[:directory],
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
          MOSAIK.configuration.collapsed,
        )
      end
    end
  end
end
