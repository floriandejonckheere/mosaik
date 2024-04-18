# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Identify microservice candidates
    #
    class Identify < Command::Graph
      self.description = "Identify microservice candidates"

      defaults structural: 1,
               logical: 1,
               contributor: 1,
               algorithm: "louvain",
               profile: false

      argument "--structural N", Float, "Weight of structural coupling (default: #{defaults[:structural]})"
      argument "--logical N", Float, "Weight of logical coupling (default: #{defaults[:logical]})"
      argument "--contributor N", Float, "Weight of contributor coupling (default: #{defaults[:contributor]})"

      argument "--algorithm ALGORITHM", "Algorithm to use for identifying microservice candidates (default: #{defaults[:algorithm]})"
      argument "--profile", "Enable profiling (default: false)"

      def validate
        super

        raise OptionError, "unknown algorithm: #{options[:algorithm]}" unless options[:algorithm].in? ["louvain"]

        return unless options[:profile]

        require "ruby-prof"
        require "ruby-prof-flamegraph"
      end

      def call
        info "Identifying microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Preprocess the graph (aggregate edges and normalize weights)
        Graph::Preprocessor
          .new(options, graph)
          .call

        RubyProf.start if options[:profile]

        # Identify microservice candidates
        Algorithms
          .const_get(options[:algorithm].camelize)
          .new(options, graph)
          .tap(&:validate)
          .call

        if options[:profile]
          profile = RubyProf.stop

          printer = RubyProf::FlameGraphPrinter.new(profile)
          printer.print(File.open("profile.html", "w+"))

          info "Profiling information written to profile.html"
        end

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
        debug graph.to_dot(options)
        graph.to_svg(file, options)

        info "Microservice candidate graph written to #{file}.gv and rendered to #{file}.svg"
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
