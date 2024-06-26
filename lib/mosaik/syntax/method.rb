# frozen_string_literal: true

module MOSAIK
  module Syntax
    ##
    # Method in the codebase
    #
    class Method
      attr_reader :constant, :name, :file, :line, :references

      def initialize(constant, name, file = nil, line = nil)
        @constant = constant
        @name = name
        @file = file
        @line = line

        @references = []
      end

      def ==(other)
        constant == other.constant &&
          name == other.name
      end

      def to_s
        [
          name,
          "#{file}:#{line}",
          "(#{references.size} references)",
        ].compact.join(" ")
      end

      def inspect
        "#<Method #{self}>"
      end
    end
  end
end
