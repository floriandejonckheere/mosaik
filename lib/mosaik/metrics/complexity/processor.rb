# frozen_string_literal: true

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

          # Calculate complexity for the method
          _, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

          # Extract complexity from <A, B, C> triplet
          complexity = abc.split(",")[1].to_f

          # Store complexity for the method
          complexities[method_name] = complexity
        end

        # Class methods
        def on_defs(node)
          method_name = "self.#{node.children[1]}"

          # Calculate complexity for the method
          _, abc = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

          # Extract complexity from <A, B, C> triplet
          complexity = abc.split(",")[1].to_i

          # Store complexity for the method
          complexities[method_name] = complexity
        end
      end
    end
  end
end
