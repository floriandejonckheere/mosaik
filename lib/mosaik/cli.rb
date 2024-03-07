# frozen_string_literal: true

require "thor"

module MOSAIK
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "version", "Display version"
    def version
      Version
        .new(options)
        .call
    end

    desc "collect", "Collect data"
    def collect
      Collect
        .new(options)
        .call
    end
  end
end
