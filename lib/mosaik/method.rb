# frozen_string_literal: true

module MOSAIK
  class Method
    attr_reader :constant, :name, :file, :line, :references

    def initialize(constant, name, file, line)
      @constant = constant
      @name = name
      @file = file
      @line = line

      @references = []
    end

    def ==(other)
      constant == other.constant &&
        name == other.name &&
        file == other.file &&
        line == other.line
    end

    def to_s
      "#{file}:#{line} #{name} (#{references.size} references)"
    end

    def inspect
      "#<Method #{self}>"
    end
  end
end
