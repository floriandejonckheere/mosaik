# frozen_string_literal: true

require "delegate"
require "logger"

require "colorize"

module MOSAIK
  ##
  # Logger class
  #
  class Logger < SimpleDelegator
    def initialize
      super(::Logger.new($stdout, formatter:))
    end

    private

    def formatter
      proc do |severity, _time, _progname, msg|
        msg = msg.inspect unless msg.is_a?(String)
        msg = "#{msg.chomp}\n"

        case severity
        when "DEBUG"
          msg = msg.cyan
        when "WARN"
          msg = msg.yellow
        when "ERROR"
          msg = msg.red
        when "FATAL"
          msg = msg.white.on_red
        end

        msg
      end
    end
  end
end
