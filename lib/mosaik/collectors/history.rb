# frozen_string_literal: true

module MOSAIK
  module Collectors
    class History
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def call
        git = Git.open(MOSAIK.options.directory, log: ::Logger.new(File::NULL))

        puts git.log
      end
    end
  end
end
