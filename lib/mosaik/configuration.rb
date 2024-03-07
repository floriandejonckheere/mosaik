# frozen_string_literal: true

# typed: true

module MOSAIK
  class Configuration
    extend T::Sig

    # Logger instance
    sig { params(logger: Logger).returns(Logger) }
    attr_writer :logger

    sig { returns(Logger) }
    def logger
      @logger ||= Logger.new
    end
  end
end
