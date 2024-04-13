# frozen_string_literal: true

require "optparse"
require "English"

module MOSAIK
  ##
  # Command line interface
  #
  class CLI
    attr_reader :options, :args, :command_args

    def initialize(args)
      @options = {
        directory: Dir.pwd,
        debug: false,
        visualize: false,
      }

      @args = args
      @command_args = []

      parse
    end

    def parse
      # Parse command line arguments (in order) and extract non-option arguments
      # (unrecognized option values). Raise for invalid option arguments (unrecognized
      # option keys). "--foo FOO --bar BAR" will result in "--foo" and "FOO" being parsed
      # correctly, "--bar" and "BAR" will be extracted.
      # This needs to be in a separate method due to the retry logic.
      parser.order!(args, into: options) { |value| @command_args << value }
    rescue OptionParser::InvalidOption => e
      @command_args += e.args
      retry
    end

    def validate
      raise OptionError, "invalid directory: #{options[:directory]}" unless File.exist?(options[:directory])
      raise OptionError, "not a directory: #{options[:directory]}" unless File.directory?(options[:directory])

      # Set log level
      MOSAIK.logger.level = options[:debug] ? "debug" : "info"

      # Set configuration
      MOSAIK.configuration = Configuration.from(File.join(options[:directory], "mosaik.yml"))
    rescue Error => e
      fatal e.message

      raise ExitError, 1
    end

    def call
      # Extract command name
      command_name = command_args.shift

      raise UsageError, "no command specified" unless command_name

      klass = "MOSAIK::Commands::#{command_name.camelize}".safe_constantize

      raise UsageError, "unknown command: #{command_name}" unless klass

      # Add command arguments to global argument parser (for the usage message)
      klass.arguments.each do |args, kwargs, block|
        parser.on(*args, **kwargs, &block)
      end
      parser.separator("\n")

      # Execute command
      command = klass
        .new(options, *command_args)

      command
        .validate

      command
        .call
    rescue UsageError => e
      # Don't print tail if no message was passed
      return usage if e.message == e.class.name

      usage(tail: "#{File.basename($PROGRAM_NAME)}: #{e.message}")
    rescue Error => e
      fatal "#{File.basename($PROGRAM_NAME)}: #{e.message}"

      raise ExitError, 1
    end

    private

    def parser
      @parser ||= OptionParser.new("#{File.basename($PROGRAM_NAME)} [global options] command [command options]") do |o|
        o.on("Global options:")
        o.on("-d", "--directory=DIRECTORY", "Set working directory") { |value| options[:directory] = File.expand_path(value) }
        o.on("-D", "--debug", "Turn on debug logging")
        o.on("--visualize", "Enable graph visualization")
        o.on("-h", "--help", "Display this message") { usage }
        o.separator("\n")
        o.on("Commands:")
        commands.each do |(name, description)|
          o.on("    #{name.ljust(33)}#{description}")
        end
        o.separator("\n")
      end
    end

    def usage(code: 1, tail: nil)
      # Extract command class usage message (if present)
      if command_args.any?
        klass = "MOSAIK::Commands::#{command_args.first.camelize}".safe_constantize

        # Add command arguments to global argument parser (for the usage message)
        klass.arguments.each do |args, kwargs, block|
          parser.on(*args, **kwargs, &block)
        end
        parser.separator("\n")
      end

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
