# frozen_string_literal: true

module MOSAIK
  module Extractors
    ##
    # Evolutionary (logical and contributor) coupling extraction
    #
    class Evolution < Extractor
      def validate
        raise OptionError, "directory is not a git repository" unless File.directory?(File.join(options[:directory], ".git"))
      end

      def call
        return unless options[:logical].positive? || options[:contributor].positive?

        # Open the git repository
        git = Git.open(options[:directory], log: ::Logger.new(File::NULL))

        # Fetch commits, limited to the last N commits
        commits = git.log(options[:limit])

        # Limit commits to the load paths
        commits = commits.path(MOSAIK.configuration.load_paths)

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

          # Select only included files
          files = files
            .map { |file, _| File.join(options[:directory], file) }
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

              graph.find_or_add_vertex(a)
              graph.find_or_add_vertex(b)

              # Add a weighted edge to the graph
              # FIXME: aggregate with existing edges
              graph.add_edge(a, b, weight: value * options[:logical])
            end
          end
        end

        # For each non-empty pair of constants in the contributor matrix (contributor coupling)
        return if options[:contributor].zero?

        info "Constructing contributor coupling graph..."

        contributors.keys.permutation(2).each do |(a, b)|
          next if contributors[a].empty? || contributors[b].empty?

          # Calculate coupling (cardinality of the intersection of sets of developers)
          coupling = (contributors[a] & contributors[b]).count

          # Skip if the coupling is one (no shared contributors)
          next if coupling == 1

          graph.find_or_add_vertex(a)
          graph.find_or_add_vertex(b)

          # Add a weighted edge to the graph
          # FIXME: aggregate with existing edges
          graph.add_edge(a, b, weight: coupling * options[:contributor])
        end
      end

      private

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
