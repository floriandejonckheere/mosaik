# frozen_string_literal: true

module MOSAIK
  class Registry
    include Enumerable

    attr_reader :hierarchy

    def initialize
      @hierarchy = Hierarchy.new
    end

    def [](constant_name)
      constants[constant_name]
    end

    def each(...)
      constants.values.each(...)
    end

    private

    def constants
      @constants ||= Hash.new { |h, k| h[k] = Constant.new(k) }
    end
  end
end
