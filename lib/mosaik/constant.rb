# frozen_string_literal: true

module MOSAIK
  class Constant
    attr_reader :name, :methods

    def initialize(name)
      @name = name

      @methods = Hash.new
    end

    def add_method(method_name, file = nil, line_num = nil)
      methods[method_name] = Method.new(self, method_name, file, line_num)
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
