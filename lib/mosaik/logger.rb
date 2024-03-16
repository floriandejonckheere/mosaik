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
        msg = "#{msg.chomp}\n"

        case severity
        when "DEBUG"
          msg = msg.cyan
        when "WARN"
          msg = msg.yellow
        when "ERROR"
          msg = msg.red
        when "FATAL"
          abort("#{File.basename($PROGRAM_NAME)}: #{msg.chomp}".white.on_red)
        end

        msg
      end
    end
  end
end
