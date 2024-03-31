# frozen_string_literal: true

module MOSAIK
  ##
  # Global options
  #
  class Options
    def directory=(path)
      @directory = File.expand_path(path)
    end

    def directory
      @directory ||= Dir.pwd
    end

    def directory?
      directory.present?
    end

    def verbose=(value)
      @verbose = value.present?
    end

    def verbose
      @verbose ||= false
    end

    def verbose?
      verbose.present?
    end

    def debug=(value)
      @debug = value.present?
    end

    def debug
      @debug ||= false
    end

    def debug?
      debug.present?
    end

    def [](key)
      send(key)
    end

    def []=(key, value)
      send(:"#{key}=", value)
    end
  end
end
