# frozen_string_literal: true

require "optparse"
require "English"

module MOSAIK
  class CLI
    attr_reader :parser, :args, :command_args

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

    def prepare
      # Validate options
      raise OptionError, "invalid directory: #{MOSAIK.options.directory}" unless File.exist?(MOSAIK.options.directory)
      raise OptionError, "not a directory: #{MOSAIK.options.directory}" unless File.directory?(MOSAIK.options.directory)
    rescue Error => e
      fatal e.message

      raise ExitError, 1
    end

    # rubocop:disable Metrics/AbcSize
    def start
      command_name = command_args.shift

      raise UsageError, "no command specified" unless command_name

      klass = "MOSAIK::Commands::#{command_name.camelize}".safe_constantize

      raise UsageError, "unknown command: #{command_name}" unless klass

      command = klass
        .new(*command_args)

      command
        .prepare

      command
        .start
    rescue UsageError => e
      # Don't print tail if no message was passed
      return usage if e.message == e.class.name

      usage(tail: "#{File.basename($PROGRAM_NAME)}: #{e.message}")
    rescue Error => e
      fatal e.message

      raise ExitError, 1
    end
    # rubocop:enable Metrics/AbcSize

    private

    def usage(code: 1, tail: nil)
      info parser.to_s
      fatal tail if tail

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
