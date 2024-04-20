# frozen_string_literal: true

require "parser"

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
          ast = ::Parser::Ruby33
            .parse_file(file)

          # Process AST to extract constants, methods and references
          Processor
            .new(tree)
            .process(ast)
        end
      end
    end
  end
end
