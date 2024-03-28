# frozen_string_literal: true

require "forwardable"
require "yaml"

require "active_support/all"
require "git"
require "ruby-graphviz"
require "zeitwerk"

module MOSAIK
  class << self
    extend Forwardable

    # Code loader instance
    attr_reader :loader

    attr_writer :logger

    def options
      @options ||= Options.new
    end

    def configuration
      @configuration ||= Configuration.from(File.join(options.directory, "mosaik.yml"))
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
      require root.join("config/initializers/inflections.rb")

      # Load initializers
      Dir[root.join("config/initializers/*.rb")].each { |f| require f }

      loader.setup
      loader.eager_load
    end
  end
end

MOSAIK.setup
