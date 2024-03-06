# frozen_string_literal: true

# typed: true

require "logger"

module MOSAIK
  class Configuration
    extend T::Sig

    # Logger instance
    sig { params(logger: Logger).returns(Logger) }
    attr_writer :logger

    sig { returns(Logger) }
    def logger
      @logger ||= Logger.new(File::NULL)
    end
  end
end
