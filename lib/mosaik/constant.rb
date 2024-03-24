# frozen_string_literal: true

module MOSAIK
  class Constant
    attr_reader :name, :methods

    def initialize(name)
      @name = name

      @methods = Hash.new { |h, k| h[k] = [] }
    end

    def ==(other)
      name == other.name
    end

    def to_s
      "#{name} (#{methods.size} methods)"
    end

    def inspect
      "#<Constant #{self}>"
    end
  end
end
