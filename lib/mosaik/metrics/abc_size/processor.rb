# frozen_string_literal: true

module MOSAIK
  module Metrics
    class ABCSize
      ##
      # Abstract Syntax Tree parser for Ruby code
      #
      class Processor < AST::Processor
        attr_reader :abc_sizes

        def initialize
          super

          # Initialize ABC sizes
          @abc_sizes = {}
        end

        # Instance methods
        def on_def(node)
          method_name = node.children[0].to_s

          # Calculate ABC size for the method
          abc_size, = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

          # Store ABC size for the method
          abc_sizes[method_name] = abc_size
        end

        # Class methods
        def on_defs(node)
          method_name = "self.#{node.children[1]}"

          # Calculate ABC size for the method
          abc_size = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(node)

          # Store ABC size for the method
          abc_sizes[method_name] = abc_size
        end
      end
    end
  end
end
