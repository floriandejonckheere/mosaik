# frozen_string_literal: true

require "delegate"
require "logger"

require "colorize"

module MOSAIK
  class Logger < SimpleDelegator
    def initialize
      super(::Logger.new($stdout, level:, formatter:))
    end

    def level
      ENV.fetch("LOG_LEVEL", "info")
    end

    private

    def formatter
      proc do |severity, _time, _progname, msg|
        abort("#{File.basename($PROGRAM_NAME)}: #{msg}".white.on_red) if severity == ::Logger::FATAL

        msg = "#{msg}\n"
        msg = msg.yellow if severity == ::Logger::DEBUG
        msg = msg.red if severity == ::Logger::ERROR

        msg
      end
    end
  end
end
