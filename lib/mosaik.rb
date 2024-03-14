# frozen_string_literal: true

require "forwardable"

require "active_support/all"
require "zeitwerk"

module MOSAIK
  class << self
    extend Forwardable

    # Code loader instance
    attr_reader :loader

    def options
      @options ||= Options.new
    end

    def logger
      @logger ||= Logger.new
    end

    def root
      @root ||= Pathname.new(File.expand_path(File.join("..", ".."), __FILE__))
    end

    def setup
      @loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)

      # Register inflections
      require root.join("config/inflections.rb")

      loader.setup
      loader.eager_load
    end
  end
end

MOSAIK.setup
