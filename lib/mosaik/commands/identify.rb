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

        raise OptionError, "file not found: #{options[:file]}" unless File.exist? options[:file]
        raise OptionError, "unknown algorithm: #{options[:algorithm]}" unless options[:algorithm].in? ["louvain"]

        return unless options[:profile]

        require "ruby-prof"
        require "ruby-prof-flamegraph"
      end

      def call
        info "Identifying microservice candidates (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})"

        # Reduce the graph
        Graph::Reducer
          .new(options, graph)
          .call

        RubyProf.start if options[:profile]

        # Save start time
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        # Identify microservice candidates
        Algorithms
          .const_get(options[:algorithm].camelize)
          .new(options, graph)
          .tap(&:validate)
          .call

        # Save end time
        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        if options[:profile]
          profile = RubyProf.stop

          printer = RubyProf::FlameGraphPrinter.new(profile)
          printer.print(File.open("profile.html", "w+"))

          info "Profiling information written to profile.html"
        end

        info "Time elapsed: #{end_time - start_time} seconds"

        # Print the clusters
        graph.clusters.each_value do |cluster|
          debug "Cluster #{cluster.id}"
          cluster.vertices.each do |vertex|
            debug "  #{vertex.id}"
          end
        end

        # Change file name
        options[:file] = "#{File.basename(options[:file], '.*')}-candidates.csv"

        # Write graph to file
        visualize
      end

      private

      def graph
        @graph ||= Graph::Graph.from_csv(File.read(options[:file]))
      end
    end
  end
end
