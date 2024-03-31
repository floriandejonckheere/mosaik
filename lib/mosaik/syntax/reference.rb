# frozen_string_literal: true

module MOSAIK
  module Syntax
    ##
    # Reference to a method in the codebase
    #
    class Reference
      attr_reader :constant, :method

      def initialize(constant, method)
        @constant = constant
        @method = method
      end

      def ==(other)
        constant == other.constant &&
          method == other.method
      end

      def to_s
        "#{constant}##{method}"
      end

      def inspect
        "#<Reference #{self}>"
      end
    end
  end
end
