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
        o.on("-h", "--help", "Display this message") { usage(exit: true) }
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

    def start
      command = command_args.shift

      raise UsageError, "no command specified" unless command

      klass = "MOSAIK::Commands::#{command.camelize}".safe_constantize

      raise UsageError, "unknown command: #{command}" unless klass

      klass
        .new(*command_args)
        .start
    rescue UsageError => e
      usage

      raise
    end

    private

    def usage(exit: false)
      info parser.to_s

      Kernel.exit if exit
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
