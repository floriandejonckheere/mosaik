# frozen_string_literal: true

require "rubocop"
require "rubocop/ast"

module MOSAIK
  module Metrics
    class ABCSize
      ##
      # Parser for Ruby code
      #
      class Parser
        def parse(file)
          debug "Parsing file: #{file}"

          # Parse Abstract Syntax Tree
          source = RuboCop::AST::ProcessedSource
            .new(File.read(file), 3.3)

          # Process AST to extract ABC sizes from methods
          processor = Processor.new

          source.ast.each_node do |node|
            processor
              .process(node)
          end

          processor.abc_sizes
        end
      end
    end
  end
end
