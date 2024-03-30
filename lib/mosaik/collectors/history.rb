# frozen_string_literal: true

module MOSAIK
  module Collectors
    class History < Collector
      def call
        # Open the git repository
        git = Git.open(MOSAIK.options.directory, log: ::Logger.new(File::NULL))

        # Fetch commits, limited to the last 1000 commits
        commits = git.log(100)

        # Limit commits to the load paths
        commits = commits.path(MOSAIK.configuration.load_paths.map { |l| File.join(MOSAIK.options.directory, l) })

        # Limit commits to a specific date
        commits = commits.since(options[:since]) if options[:since]

        info "Analyzing #{commits.count} commits"

        # Create a nested mapping for each pair of nodes in the graph
        matrix = Hash.new { |h, k| h[k] = Hash.new(0) }

        # Calculate the aggregated local coupling
        commits.each do |commit|
          # Get the files for the commit
          files = commit.diff_parent.stats[:files]

          # Reject files not in the load paths
          files = files
            .map { |file, _| File.join(MOSAIK.options.directory, file) }
            .select { |file| file.in? MOSAIK.configuration.files }

          # Resolve file paths to class name
          constants = files.map do |file|
            resolver.resolve!(file)
          end

          debug "Commit #{commit.sha} (#{constants.count} constants: #{constants.join(', ')})"

          # Calculate the local coupling
          constants
            .permutation(2)
            .each { |(a, b)| matrix[a][b] += 1 }
        end

        debug "Building graph..."

        # For each non-zero element in the matrix, add an edge to the graph
        matrix.each do |a, row|
          row.each do |b, value|
            next if value.zero?

            # Add an edge from the node to the receiver
            graph.add_edge(a, b, label: value)
          end
        end
      end

      private

      def resolver
        @resolver ||= Resolver.new(
          MOSAIK.options.directory,
          MOSAIK.configuration.load_paths,
          MOSAIK.configuration.overrides,
        )
      end
    end
  end
end
