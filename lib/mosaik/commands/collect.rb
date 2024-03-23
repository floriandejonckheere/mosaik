# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        include_patterns = MOSAIK.configuration.include.map { |i| "#{MOSAIK.options.directory}/#{i}" }
        exclude_patterns = MOSAIK.configuration.exclude.map { |e| "#{MOSAIK.options.directory}/#{e}" }

        included_files = Dir[*include_patterns]
        excluded_files = Dir[*exclude_patterns]

        included_files - excluded_files
      end
    end
  end
end
