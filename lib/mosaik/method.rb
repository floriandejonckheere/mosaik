# frozen_string_literal: true

module MOSAIK
  class Method
    attr_reader :name, :file, :line, :references

    def initialize(name, file, line)
      @name = name
      @file = file
      @line = line

      @references = []
    end

    def to_s
      "#{file}:#{line} #{name} (#{references.size} references)"
    end

    def inspect
      "#<Method #{self}>"
    end
  end
end
