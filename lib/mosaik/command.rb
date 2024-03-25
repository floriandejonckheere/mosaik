# frozen_string_literal: true

module MOSAIK
  class Command
    class_attribute :description

    class_attribute :options,
                    default: {}

    class_attribute :arguments,
                    default: [["Command options:", {}, nil]]

    attr_reader :options

    def initialize(*command_args)
      # Initialize options with default values
      @options = self.class.options.dup

      # Parse command arguments
      self.class.parser.parse!(command_args, into: @options)

      # Transform keys to symbols
      @options.transform_keys! { |k| k.to_s.underscore.to_sym }
    rescue OptionParser::ParseError => e
      raise UsageError, e.message
    end

    def self.parser
      @parser ||= OptionParser.new.tap do |o|
        arguments.each do |args, kwargs, block|
          o.on(*args, **kwargs, &block)
        end
      end
    end

    def self.argument(*args, **kwargs, &block)
      self.arguments << [args, kwargs, block] # rubocop:disable Style/RedundantSelf
    end

    def self.defaults(**kwargs)
      self.options = self.options.merge(kwargs) # rubocop:disable Style/RedundantSelf
    end

    def prepare; end

    def start; end
  end
end
