# frozen_string_literal: true

module MOSAIK
  module Syntax
    ##
    # Constant in the codebase
    #
    class Constant
      attr_reader :name, :methods, :parent, :descendants

      attr_accessor :type

      def initialize(name, parent = nil, type = "class")
        @name = name
        @parent = parent
        @type = type

        @methods = {}
        @descendants = Set.new
      end

      def add_method(method_name, file = nil, line_num = nil)
        methods[method_name] = Method.new(self, method_name, file, line_num)
      end

      def hash
        name.hash
      end

      def ==(other)
        name == other.name
      end

      def to_s
        "#{name} (#{methods.size} methods)"
      end

      def inspect
        "#<#{name} #{self}>"
      end
    end
  end
end
