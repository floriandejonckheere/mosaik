# frozen_string_literal: true

module MOSAIK
  class Configuration
    def logger
      @logger ||= Logger.new
    end
  end
end
