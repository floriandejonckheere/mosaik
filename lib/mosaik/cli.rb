# frozen_string_literal: true

require "optparse"
require "English"

module MOSAIK
  class CLI
    attr_reader :parser, :args, :command_args

    # rubocop:disable Metrics/AbcSize
    def initialize(args)
      @parser = OptionParser.new("#{File.basename($PROGRAM_NAME)} [global options] command [command options]") do |o|
        o.on("Global options:")
        o.on("-d", "--directory=DIRECTORY", "Set working directory")
        o.on("-v", "--verbose", "Turn on verbose logging")
        o.on("-D", "--debug", "Turn on debug logging")
        o.on("-h", "--help", "Display this message") { usage }
        o.separator("\n")
        o.on("Commands:")
        commands.each do |(name, description)|
          o.on("    #{name.ljust(33)}#{description}")
        end
        o.separator("\n")
      end

      @args = args
      @command_args = []

      parse!
    end
    # rubocop:enable Metrics/AbcSize

    def parse!
      # Parse command line arguments (in order) and extract non-option arguments
      # (unrecognized option values). Raise for invalid option arguments (unrecognized
      # option keys). "--foo FOO --bar BAR" will result in "--foo" and "FOO" being parsed
      # correctly, "--bar" and "BAR" will be extracted.
      parser.order!(args, into: MOSAIK.options) { |value| command_args << value }
    rescue OptionParser::InvalidOption => e
      @command_args += e.args
      retry
    end

    # rubocop:disable Metrics/AbcSize
    def start
      command = command_args.shift

      raise UsageError, "no command specified" unless command

      klass = "MOSAIK::Commands::#{command.camelize}".safe_constantize

      raise UsageError, "unknown command: #{command}" unless klass

      klass
        .new(*command_args)
        .start
    rescue UsageError => e
      # Don't print tail if no message was passed
      return usage if e.message == e.class.name

      usage(tail: "#{File.basename($PROGRAM_NAME)}: #{e.message}")
    rescue Error => e
      MOSAIK.logger.fatal e.message
    end
    # rubocop:enable Metrics/AbcSize

    private

    def usage(code: 1, tail: nil)
      MOSAIK.logger.info parser.to_s
      MOSAIK.logger.info tail if tail

      raise ExitError, code
    end

    def commands
      Command.descendants.sort_by(&:name).map do |k|
        [
          k.name.demodulize.underscore,
          k.description,
        ]
      end
    end
  end
end
