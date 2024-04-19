# frozen_string_literal: true

module MOSAIK
  module Extractors
    class Structural
      ##
      # Parser for Ruby code
      #
      class Parser
        def parse(file, tree)
          debug "Parsing file: #{file}"

          # Parse Abstract Syntax Tree
          source = RuboCop::AST::ProcessedSource
            .new(File.read(file), 3.3)

          # Process AST to extract constants, methods and references
          processor = Processor.new(tree)

          source.ast.each_node do |node|
            processor
              .process(node)
          end
        end
      end
    end
  end
end
