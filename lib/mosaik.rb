# frozen_string_literal: true

require "forwardable"
require "yaml"

require "active_support/all"
require "git"
require "sorbet-runtime"
require "zeitwerk"

module MOSAIK
  class << self
    extend Forwardable

    # Code loader instance
    attr_reader :loader

    # Logger
    attr_writer :logger

    # Configuration
    attr_accessor :configuration

    def logger
      @logger ||= Logger.new
    end

    def root
      @root ||= Pathname.new(File.expand_path(File.join("..", ".."), __FILE__))
    end

    def setup
      @loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)

      # Register inflections
      require root.join("config/initializers/inflections.rb")

      # Load initializers
      Dir[root.join("config/initializers/*.rb")].each { |f| require f }

      loader.setup
      loader.eager_load
    end
  end
end

MOSAIK.setup
