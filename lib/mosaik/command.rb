# frozen_string_literal: true

module MOSAIK
  class Command
    class << self
      attr_accessor :description
    end

    attr_reader :args

    def initialize(*args)
      @args = args
    end

    def prepare; end

    def start; end
  end
end
