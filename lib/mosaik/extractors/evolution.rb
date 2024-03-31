# frozen_string_literal: true

module MOSAIK
  module Extractors
    ##
    # Evolutionary (logical and contributor) coupling extraction
    #
    class Evolution < Extractor
      def call
        return unless options[:logical].positive? || options[:contributor].positive?

        # Open the git repository
        git = Git.open(MOSAIK.options.directory, log: ::Logger.new(File::NULL))

        # Fetch commits, limited to the last N commits
        commits = git.log(options[:limit]) if options[:limit]

        # Limit commits to the load paths
        commits = commits.path(MOSAIK.configuration.load_paths.map { |l| File.join(MOSAIK.options.directory, l) })

        # Limit commits to a specific date
        commits = commits.since(options[:since]) if options[:since]

        info "Analyzing #{commits.count} commits"

        # Create a co-change matrix for each pair of constants (logical coupling)
        co_changes = Hash.new { |h, k| h[k] = Hash.new(0) }

        # Create a contributor matrix for each constant (contributor coupling)
        contributors = Hash.new { |h, k| h[k] = Set.new }

        # Iterate over each commit
        commits.each do |commit|
          # Get the files for the commit
          files = commit.diff_parent.stats[:files]

          # Reject files not in the load paths
          files = files
            .map { |file, _| File.join(MOSAIK.options.directory, file) }
            .select { |file| file.in? MOSAIK.configuration.files }

          # Resolve file paths to class name
          constants = files.map { |file| resolver.resolve!(file) }

          debug "Commit #{commit.sha} (#{constants.count} constants: #{constants.join(', ')})"

          # Increment the co-change number between each pair of constants (logical coupling)
          constants
            .permutation(2)
            .each { |(a, b)| co_changes[a][b] += 1 }

          # Add the commit author to the contributors for each constant (contributor coupling)
          constants.each { |constant| contributors[constant] << commit.author.email }
        end

        # For each non-zero pair of constants in the co-change matrix (logical coupling)
        unless options[:logical].zero?
          info "Constructing logical coupling graph..."

          co_changes.each do |a, row|
            row.each do |b, value|
              next if value.zero?

              # Add a weighted edge to the graph
              graph.add_directed_edge(a, b, value)
            end
          end
        end

        # For each non-empty pair of constants in the contributor matrix (contributor coupling)
        return if options[:contributor].zero?

        info "Constructing contributor coupling graph..."

        contributors.keys.permutation(2).each do |(a, b)|
          next if contributors[a].empty? || contributors[b].empty?

          # Add a weighted edge to the graph (weight is the cardinality of the intersection of sets)
          graph.add_directed_edge(a, b, (contributors[a] & contributors[b]).count)
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
