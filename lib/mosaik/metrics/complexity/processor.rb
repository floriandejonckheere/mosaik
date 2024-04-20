# frozen_string_literal: true

require "rubocop"

module MOSAIK
  module Metrics
    class Complexity
      ##
      # Abstract Syntax Tree parser for Ruby code
      #
      class Processor < AST::Processor
        attr_reader :complexities

        def initialize
          super

          # Initialize complexities
          @complexities = {}
        end

        # Instance methods
        def on_def(node)
          method_name = node.children[0].to_s

          # Calculate and store complexity for the method
          complexities[method_name] = complexity_for(node)
        end

        # Class methods
        def on_defs(node)
          method_name = "self.#{node.children[1]}"

          # Calculate and store complexity for the method
          complexities[method_name] = complexity_for(node)
        end

        private

        def complexity_for(node)
          # Calculate complexity
          _, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

          # Extract complexity from <A, B, C> triplet
          abc.split(",")[1].to_i

          # Return complexity
        end
      end
    end
  end
end
